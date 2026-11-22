import gleeunit/should
import grrr/post.{Empty, TooLong}

pub fn valid_body_trims_whitespace_test() {
  let assert Ok(body) = post.new_body("  hello gleam 🐻  ")
  post.to_string(body)
  |> should.equal("hello gleam 🐻")
}

pub fn whitespace_only_is_empty_error_test() {
  post.new_body("   \n\t  ")
  |> should.equal(Error(Empty))
}

pub fn over_280_graphemes_is_too_long_test() {
  let long = "a" |> repeat(281)
  post.new_body(long)
  |> should.equal(Error(TooLong(length: 281, max: 280)))
}

fn repeat(s: String, times: Int) -> String {
  case times <= 0 {
    True -> ""
    False -> s <> repeat(s, times - 1)
  }
}
