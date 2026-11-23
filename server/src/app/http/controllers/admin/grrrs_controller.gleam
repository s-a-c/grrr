import app/app.{type App}
import compiled/loom/admin/grrrs as grrrs_view
import database/main/models/grrr/gen/grrr
import glimr/http/context.{type Context}
import glimr/http/response.{type Response}

/// Render the Loom Admin Moderation Feed.
///
/// @get "/admin/grrrs"
///
pub fn index(ctx: Context(App)) -> Response {
  use items <- grrr.list_recent_or_fail(ctx.app.db)

  grrrs_view.render(grrrs: items)
  |> response.string_tree(200)
}
