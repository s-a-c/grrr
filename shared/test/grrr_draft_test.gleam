import gleam/string
import gleeunit/should
import grrr/handle
import grrr/post.{Empty, InvalidBody, InvalidHandle, TooLong}

pub fn valid_draft_normalizes_handle_and_body_test() {
  let assert Ok(draft) = post.new_draft("  @Bear_Dev ", "  Hello grrr! 🐻 ")
  handle.to_string(draft.author) |> should.equal("@bear_dev")
  post.to_string(draft.body) |> should.equal("Hello grrr! 🐻")
}

pub fn invalid_handle_short_circuits_before_body_test() {
  // Both handle AND body are invalid — handle error wins first
  post.new_draft("ab", "")
  |> should.equal(Error(InvalidHandle(handle.TooShort(length: 2, min: 3))))
}

pub fn invalid_body_returns_invalid_body_error_test() {
  post.new_draft("@valid_user", "   ")
  |> should.equal(Error(InvalidBody(Empty)))
}

pub fn exact_280_graphemes_is_allowed_test() {
  let max_emojis = string.repeat("🐻", 280)
  let assert Ok(draft) = post.new_draft("bear", max_emojis)
  string.length(post.to_string(draft.body)) |> should.equal(280)
}

pub fn over_280_graphemes_returns_too_long_test() {
  let over = string.repeat("a", 281)
  post.new_draft("bear", over)
  |> should.equal(Error(InvalidBody(TooLong(length: 281, max: 280))))
}

pub fn new_draft_all_accumulates_both_errors_test() {
  post.new_draft_all("ab", "   ")
  |> should.equal(
    Error([
      InvalidHandle(handle.TooShort(length: 2, min: 3)),
      InvalidBody(Empty),
    ]),
  )
}

pub fn new_draft_all_returns_single_error_when_one_field_fails_test() {
  post.new_draft_all("bad!handle", "valid post")
  |> should.equal(Error([InvalidHandle(handle.InvalidChars)]))

  post.new_draft_all("@bear_dev", "")
  |> should.equal(Error([InvalidBody(Empty)]))
}

pub fn new_draft_all_succeeds_when_both_fields_valid_test() {
  let assert Ok(draft) = post.new_draft_all("@Bear_Dev", "All fields valid! 🐻")
  handle.to_string(draft.author) |> should.equal("@bear_dev")
  post.to_string(draft.body) |> should.equal("All fields valid! 🐻")
}
