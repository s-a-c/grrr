import gleam/list
import gleam/string

pub opaque type Handle {
  Handle(String)
}

pub type HandleError {
  TooShort(length: Int, min: Int)
  TooLong(length: Int, max: Int)
  InvalidChars
}

pub fn new(raw: String) -> Result(Handle, HandleError) {
  let cleaned =
    raw
    |> string.trim
    |> strip_leading_at
    |> string.lowercase

  let len = string.length(cleaned)
  case len {
    n if n < 3 -> Error(TooShort(length: n, min: 3))
    n if n > 15 -> Error(TooLong(length: n, max: 15))
    _ ->
      case is_valid_chars(cleaned) {
        True -> Ok(Handle(cleaned))
        False -> Error(InvalidChars)
      }
  }
}

pub fn to_string(handle: Handle) -> String {
  let Handle(name) = handle
  "@" <> name
}

fn strip_leading_at(s: String) -> String {
  case string.starts_with(s, "@") {
    True -> string.drop_start(s, 1)
    False -> s
  }
}

fn is_valid_chars(s: String) -> Bool {
  s
  |> string.to_graphemes
  |> list.all(fn(ch) {
    string.contains("abcdefghijklmnopqrstuvwxyz0123456789_", ch)
  })
}
