import gleam/string

pub const max_body_length = 280

pub opaque type GrrrBody {
  GrrrBody(String)
}

pub type BodyError {
  Empty
  TooLong(length: Int, max: Int)
}

pub fn new_body(raw: String) -> Result(GrrrBody, BodyError) {
  let trimmed = string.trim(raw)
  let len = string.length(trimmed)

  case len {
    0 -> Error(Empty)
    n if n > max_body_length -> Error(TooLong(length: n, max: max_body_length))
    _ -> Ok(GrrrBody(trimmed))
  }
}

pub fn to_string(body: GrrrBody) -> String {
  let GrrrBody(text) = body
  text
}
