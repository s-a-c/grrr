import app/app.{type App}
import database/main/models/grrr/gen/grrr.{type Grrr}
import gleam/json
import glimr/http/context.{type Context}
import glimr/http/response.{type Response}

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

fn encode_grrr(item: Grrr) -> json.Json {
  json.object([
    #("id", json.string(item.uuid)),
    #("author_handle", json.string(item.author_handle)),
    #("body", json.string(item.body)),
    #("created_at", json.int(item.created_at)),
  ])
}
