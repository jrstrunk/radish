import gleam/bit_array
import gleam/io
import radish/decoder
import radish/error
import radish/resp
import gleam/result

import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const packets = [
  #(
    True,
    <<
      "*14\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n":utf8,
    >>,
  ),
  #(
    False,
    <<
      "*140\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132":utf8,
    >>,
  ),
  #(
    False,
    <<
      "*140\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$5\r\n132.1\r\n$5\r\n132.2\r\n$5\r\n132.3":utf8,
    >>,
  ),
  #(
    True,
    <<
      "*140\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.35\r\n$6\r\n132.32\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$5\r\n132.3\r\n$5\r\n132.3\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$5\r\n132.3\r\n$5\r\n132.3\r\n":utf8,
    >>,
  ),
  #(True, <<"*2\r\n$7\r\nnumsbig\r\n$9\r\nnumssmall\r\n":utf8>>),
  #(
    True,
    <<
      "%7\r\n$6\r\nserver\r\n$5\r\nredis\r\n$7\r\nversion\r\n$5\r\n7.2.4\r\n$5\r\nproto\r\n:3\r\n$2\r\nid\r\n:3\r\n$4\r\nmode\r\n$10\r\nstandalone\r\n$4\r\nrole\r\n$6\r\nmaster\r\n$7\r\nmodules\r\n*0\r\n":utf8,
    >>,
  ),
  #(
    False,
    <<
      "$2331\r\nAika is a smart and athletic high school girl. She is so competent that she successfully passes the salvagers license test, obtaining a C-class license. Yet, she is young and hotheaded, so much so that Gota still treats her as a child. Due to this personality, no one is willing to hire her for salvaging jobs.Since she had taken the trouble to get her license, she decides to post an ad in her school to attract clients. She manages to get the attention of Erika, a daughter of a rich family and the leader of the treasure hunting club. She asks Aika to salvage something from the sea and Aika delightfully accepts the request.However, upon seeing the state-of-the-art submarine loaded onto Erika's private cruiser and discovering their destination, Aika realizes the terrible nature of her assignment. This results in a clash with a group of high school girls in the southern islands.Who is the mysterious girl named Karen? So begins Aika's newest challenge!Aika's story continues, she is now 19 years-old, 3 years older than in R-16 and 7 younger than in Agent AIKa. Strange phenomena have been occuring at a girls academy. Slowly but persistently the most cute and beautiful girls are joining an internal club, but instead of a sing-in they just get abducted by a strange being that takes control over them by some indecent means.By coincidence Aika was flying-by on her plane when one of this abductions occurred and she was attacked to prevent her":utf8,
    >>,
  ),
  #(
    True,
    <<
      "$2331\r\nAika is a smart and athletic high school girl. She is so competent that she successfully passes the salvagers license test, obtaining a C-class license. Yet, she is young and hotheaded, so much so that Gota still treats her as a child. Due to this personality, no one is willing to hire her for salvaging jobs.Since she had taken the trouble to get her license, she decides to post an ad in her school to attract clients. She manages to get the attention of Erika, a daughter of a rich family and the leader of the treasure hunting club. She asks Aika to salvage something from the sea and Aika delightfully accepts the request.However, upon seeing the state-of-the-art submarine loaded onto Erika's private cruiser and discovering their destination, Aika realizes the terrible nature of her assignment. This results in a clash with a group of high school girls in the southern islands.Who is the mysterious girl named Karen? So begins Aika's newest challenge!Aika's story continues, she is now 19 years-old, 3 years older than in R-16 and 7 younger than in Agent AIKa. Strange phenomena have been occuring at a girls academy. Slowly but persistently the most cute and beautiful girls are joining an internal club, but instead of a sing-in they just get abducted by a strange being that takes control over them by some indecent means.By coincidence Aika was flying-by on her plane when one of this abductions occurred and she was attacked to prevent her from comming closer, but instead of repelling her, she is intrigued about the attack's origin and then the opportunity shows up when her late partners from R-16 decide to investigate those abductions. The story remains full of action and panty flashing that are a must in Aika's series.Minase, a high school student, found a book of magic in an isolated room in his school. He started practicing black magic that has extreme sexual effects that benefited him and some of his friends. Intrigued, Minase got deeper and deeper into using the craft, not realizing the evils that will come forth. Eventually, the origins of the book was revealed, and so did the incident twelve years ago on the night of the Walpurgis, the night when the power of evil is at its strongest. After coming to his senses, Minase struggles to get himself out of the darkness that he had put himself into.\r\n":utf8,
    >>,
  ),
  #(True, <<":2\r\n":utf8>>),
  #(True, <<":140\r\n":utf8>>),
  #(True, <<"*1\r\n$6\r\n132.13\r\n":utf8>>),
  #(True, <<"*0\r\n":utf8>>),
  #(True, <<"$6\r\n132.13\r\n":utf8>>),
]

// pub fn bitstring_test() {
//   let start =
//     "hello"
//     |> bit_array.from_string
//     |> io.debug

//   let size =
//     start
//     |> bit_array.byte_size

//   start
//   |> bit_array.slice(size, -1)
//   |> io.debug
// }

pub fn consume_by_length_test() {
  <<"hello\r\nthis is another\r\n":utf8>>
  |> decoder.consume_by_length(5, <<>>)
  |> should.equal(Ok(#(<<"hello":utf8>>, <<"\r\nthis is another\r\n":utf8>>)))
}

pub fn consume_by_length_error_test() {
  <<"hello\r\nthis is another\r\n":utf8>>
  |> decoder.consume_by_length(100, <<>>)
  |> should.equal(Error(Nil))
}

pub fn decode_list_test() {
  bit_array.from_string(
    "*14\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n",
  )
  |> decoder.decode
  // |> io.debug

  bit_array.from_string(
    "*140\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132",
  )
  |> decoder.decode
  // |> io.debug

  bit_array.from_string(
    "*140\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.34\r\n$6\r\n132.33\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$6\r\n132.35\r\n$6\r\n132.32\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$5\r\n132.3\r\n$5\r\n132.3\r\n$6\r\n132.13\r\n$6\r\n132.13\r\n$6\r\n132.28\r\n$5\r\n132.2\r\n$6\r\n132.25\r\n$5\r\n132.3\r\n$5\r\n132.3\r\n",
  )
  |> decoder.decode
  // |> io.debug
}
