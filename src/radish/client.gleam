import gleam/bit_array
import gleam/erlang/process
import gleam/otp/actor

import radish/decoder.{decode}
import radish/error
import radish/resp.{type Value}
import radish/tcp

import mug.{type Error}

pub type Message {
  Shutdown
  Command(BitArray, process.Subject(Result(List(Value), error.Error)), Int)
  BlockingCommand(
    BitArray,
    process.Subject(Result(List(Value), error.Error)),
    Int,
  )
  ReceiveForever(process.Subject(Result(List(Value), error.Error)), Int)
}

pub fn start(host: String, port: Int, timeout: Int) {
  actor.start_spec(actor.Spec(
    init: fn() {
      case tcp.connect(host, port, timeout) {
        Ok(socket) -> actor.Ready(socket, process.new_selector())
        Error(_) -> actor.Failed("Unable to connect to Redis server")
      }
    },
    init_timeout: timeout,
    loop: handle_message,
  ))
}

fn handle_message(msg: Message, socket: mug.Socket) {
  case msg {
    Command(cmd, reply_with, timeout) -> {
      case tcp.send(socket, cmd) {
        Ok(Nil) -> {
          let selector = tcp.new_selector()
          case receive(socket, selector, <<>>, <<>>, now(), timeout) {
            Ok(reply) -> {
              actor.send(reply_with, Ok(reply))
              actor.continue(socket)
            }

            Error(error) -> {
              let _ = mug.shutdown(socket)
              actor.send(reply_with, Error(error))
              actor.Stop(process.Abnormal("TCP Error"))
            }
          }
        }

        Error(error) -> {
          let _ = mug.shutdown(socket)
          actor.send(reply_with, Error(error.TCPError(error)))
          actor.Stop(process.Abnormal("TCP Error"))
        }
      }
    }

    BlockingCommand(cmd, reply_with, timeout) -> {
      case tcp.send(socket, cmd) {
        Ok(Nil) -> {
          let selector = tcp.new_selector()

          case receive_forever(socket, selector, <<>>, now(), timeout) {
            Ok(reply) -> {
              actor.send(reply_with, Ok(reply))
              actor.continue(socket)
            }

            Error(error) -> {
              let _ = mug.shutdown(socket)
              actor.send(reply_with, Error(error))
              actor.Stop(process.Abnormal("TCP Error"))
            }
          }
        }

        Error(error) -> {
          let _ = mug.shutdown(socket)
          actor.send(reply_with, Error(error.TCPError(error)))
          actor.Stop(process.Abnormal("TCP Error"))
        }
      }
    }

    ReceiveForever(reply_with, timeout) -> {
      let selector = tcp.new_selector()

      case receive_forever(socket, selector, <<>>, now(), timeout) {
        Ok(reply) -> {
          actor.send(reply_with, Ok(reply))
          actor.continue(socket)
        }

        Error(error) -> {
          let _ = mug.shutdown(socket)
          actor.send(reply_with, Error(error))
          actor.Stop(process.Abnormal("TCP Error"))
        }
      }
    }

    Shutdown -> {
      let _ = mug.shutdown(socket)
      actor.Stop(process.Normal)
    }
  }
}

fn receive(
  socket: mug.Socket,
  selector: process.Selector(Result(BitArray, mug.Error)),
  to_decode_acc: BitArray,
  decoded_acc: BitArray,
  start_time: Int,
  timeout: Int,
) {
  case decode(to_decode_acc) {
    Ok(value) -> Ok(value)
    Error(error) -> {
      case now() - start_time >= timeout * 1_000_000 {
        True -> Error(error)
        False ->
          case tcp.receive(socket, selector, timeout) {
            Error(tcp_error) -> Error(error.TCPError(tcp_error))
            Ok(packet) ->
              receive(
                socket,
                selector,
                bit_array.append(to_decode_acc, packet),
                <<>>,
                start_time,
                timeout,
              )
          }
      }
    }
  }
}

fn receive_forever(
  socket: mug.Socket,
  selector: process.Selector(Result(BitArray, mug.Error)),
  storage: BitArray,
  start_time: Int,
  timeout: Int,
) {
  case decode(storage) {
    Ok(value) -> Ok(value)

    Error(error) if timeout != 0 -> {
      case now() - start_time >= timeout * 1_000_000 {
        True -> Error(error)
        False ->
          case tcp.receive_forever(socket, selector) {
            Error(tcp_error) -> Error(error.TCPError(tcp_error))
            Ok(packet) ->
              receive_forever(
                socket,
                selector,
                bit_array.append(storage, packet),
                start_time,
                timeout,
              )
          }
      }
    }

    Error(_) -> {
      case tcp.receive_forever(socket, selector) {
        Error(tcp_error) -> Error(error.TCPError(tcp_error))
        Ok(packet) ->
          receive_forever(
            socket,
            selector,
            bit_array.append(storage, packet),
            start_time,
            timeout,
          )
      }
    }
  }
}

@external(erlang, "erlang", "monotonic_time")
fn now() -> Int
