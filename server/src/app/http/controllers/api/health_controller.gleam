import gleam/json
import glimr/http/response.{type Response}
import grrr/handle
import grrr/post

/// Health & shared-domain smoke endpoint for grrr.
///
/// @get "/api/health"
///
pub fn show() -> Response {
  let assert Ok(draft) =
    post.new_draft("@grrr_bot", "Glimr + shared/ is alive on BEAM! 🐻")

  json.object([
    #("status", json.string("ok")),
    #("sample_author", json.string(handle.to_string(draft.author))),
    #("sample_body", json.string(post.to_string(draft.body))),
    #("max_body_length", json.int(post.max_body_length)),
  ])
  |> response.json(200)
}
