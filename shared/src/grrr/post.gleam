import gleam/result
import gleam/string
import grrr/handle.{type Handle, type HandleError}

pub const max_body_length = 280

pub opaque type GrrrBody {
  GrrrBody(String)
}

pub type BodyError {
  Empty
  TooLong(length: Int, max: Int)
}

pub type DraftGrrr {
  DraftGrrr(author: Handle, body: GrrrBody)
}

pub type DraftError {
  InvalidHandle(HandleError)
  InvalidBody(BodyError)
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

pub fn new_draft(
  raw_author: String,
  raw_body: String,
) -> Result(DraftGrrr, DraftError) {
  use author <- result.try(
    handle.new(raw_author) |> result.map_error(InvalidHandle),
  )
  use body <- result.try(new_body(raw_body) |> result.map_error(InvalidBody))

  Ok(DraftGrrr(author:, body:))
}

/// Validates both author handle and post body independently, returning all
/// errors at once for form UX (instead of short-circuiting on the first error).
pub fn new_draft_all(
  raw_author: String,
  raw_body: String,
) -> Result(DraftGrrr, List(DraftError)) {
  case handle.new(raw_author), new_body(raw_body) {
    Ok(author), Ok(body) -> Ok(DraftGrrr(author:, body:))
    Error(h_err), Ok(_) -> Error([InvalidHandle(h_err)])
    Ok(_), Error(b_err) -> Error([InvalidBody(b_err)])
    Error(h_err), Error(b_err) ->
      Error([InvalidHandle(h_err), InvalidBody(b_err)])
  }
}
