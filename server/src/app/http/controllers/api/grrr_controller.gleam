import app/app.{type App}
import database/main/models/grrr/gen/grrr.{type Grrr}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/time/duration
import gleam/time/timestamp
import glimr/http/context.{type Context}
import glimr/http/response.{type Response}
import grrr/handle
import grrr/post.{type DraftError, Empty, InvalidBody, InvalidHandle, TooLong}
import wisp
import youid/uuid

// docs: https://github.com/glimr-org/glimr?tab=readme-ov-file#creating-controllers
// docs: https://github.com/glimr-org/glimr?tab=readme-ov-file#views--responses
// docs: https://github.com/glimr-org/glimr?tab=readme-ov-file#redirects

/// List the 50 most recent Grrrs as JSON.
///
/// @get "/api/grrrs"
///
pub fn index(ctx: Context(App)) -> Response {
  use grrrs <- grrr.list_recent_or_fail(ctx.app.db)

  json.object([
    #("grrrs", json.array(grrrs, encode_grrr)),
  ])
  |> response.json(200)
}

/// Validate and persist a new Grrr with a time-ordered UUIDv7.
///
/// @post "/api/grrrs"
///
pub fn store(ctx: Context(App)) -> Response {
  use json_body <- wisp.require_json(ctx.req)

  let payload_decoder = {
    use author <- decode.field("author", decode.string)
    use body <- decode.field("body", decode.string)
    decode.success(#(author, body))
  }

  case decode.run(json_body, payload_decoder) {
    Error(_) ->
      json.object([
        #("error", json.string("Expected JSON with author and body strings")),
      ])
      |> response.json(400)

    Ok(#(raw_author, raw_body)) ->
      case post.new_draft_all(raw_author, raw_body) {
        Error(errors) ->
          json.object([#("errors", json.array(errors, encode_draft_error))])
          |> response.json(422)

        Ok(draft) -> {
          let now =
            timestamp.system_time()
            |> timestamp.to_rfc3339(duration.seconds(0))
          let id = uuid.v7_string()

          use saved <- grrr.create_or_fail(
            pool: ctx.app.db,
            uuid: id,
            author_handle: handle.to_string(draft.author),
            body: post.to_string(draft.body),
            created_at: now,
            updated_at: now,
          )

          json.object([#("grrr", encode_grrr(saved))])
          |> response.json(201)
        }
      }
  }
}

fn encode_grrr(item: Grrr) -> json.Json {
  json.object([
    #("id", json.string(item.uuid)),
    #("author_handle", json.string(item.author_handle)),
    #("body", json.string(item.body)),
    #("created_at", json.string(item.created_at)),
  ])
}

fn encode_draft_error(err: DraftError) -> json.Json {
  let #(field, message) = case err {
    InvalidHandle(handle.TooShort(len, min)) -> #(
      "author",
      "Handle too short ("
        <> int.to_string(len)
        <> "/"
        <> int.to_string(min)
        <> " min)",
    )
    InvalidHandle(handle.TooLong(len, max)) -> #(
      "author",
      "Handle too long ("
        <> int.to_string(len)
        <> "/"
        <> int.to_string(max)
        <> " max)",
    )
    InvalidHandle(handle.InvalidChars) -> #(
      "author",
      "Handle may only contain letters, numbers, and underscores",
    )
    InvalidBody(Empty) -> #("body", "Grrr body cannot be empty")
    InvalidBody(TooLong(len, max)) -> #(
      "body",
      "Grrr body too long ("
        <> int.to_string(len)
        <> "/"
        <> int.to_string(max)
        <> " max)",
    )
  }

  json.object([
    #("field", json.string(field)),
    #("message", json.string(message)),
  ])
}
