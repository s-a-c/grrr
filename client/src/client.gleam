import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/string
import grrr/handle
import grrr/post.{
  type DraftError, type DraftGrrr, Empty, InvalidBody, InvalidHandle, TooLong,
}
import lustre
import lustre/attribute.{class, disabled, placeholder, type_, value}
import lustre/effect.{type Effect}
import lustre/element.{type Element, text}
import lustre/element/html.{
  button, div, form, h1, header, input, li, p, span, textarea, ul,
}
import lustre/event
import rsvp

@external(javascript, "./ws_ffi.mjs", "connect_timeline")
fn connect_timeline(
  path: String,
  on_status: fn(Bool) -> Nil,
  on_message: fn(String) -> Nil,
) -> Nil

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

pub type PostedGrrr {
  PostedGrrr(id: String, author: String, body: String, created_at: String)
}

pub type Model {
  Model(
    author: String,
    body: String,
    errors: List(String),
    grrrs: List(PostedGrrr),
    loading: Bool,
    submitting: Bool,
    online: Int,
    ws_connected: Bool,
  )
}

pub type Msg {
  AuthorChanged(String)
  BodyChanged(String)
  Submitted
  GrrrsFetched(Result(List(PostedGrrr), rsvp.Error(String)))
  GrrrPosted(Result(PostedGrrr, rsvp.Error(String)))
  WsStatusChanged(Bool)
  WsFrameReceived(String)
}

type WsEvent {
  PresenceEvent(online: Int)
  GrrrCreatedEvent(grrr: PostedGrrr)
}

fn init(_flags) -> #(Model, Effect(Msg)) {
  let model =
    Model(
      author: "@bear_dev",
      body: "",
      errors: [],
      grrrs: [],
      loading: True,
      submitting: False,
      online: 0,
      ws_connected: False,
    )
  #(model, effect.batch([fetch_grrrs(), subscribe_timeline()]))
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    AuthorChanged(author) -> #(
      Model(..model, author: author, errors: []),
      effect.none(),
    )

    BodyChanged(body) -> #(
      Model(..model, body: body, errors: []),
      effect.none(),
    )

    Submitted ->
      case model.submitting {
        True -> #(model, effect.none())
        False ->
          case post.new_draft_all(model.author, model.body) {
            Error(errs) -> #(
              Model(..model, errors: list.map(errs, format_error)),
              effect.none(),
            )

            Ok(draft) -> #(
              Model(..model, errors: [], submitting: True),
              post_grrr(draft),
            )
          }
      }

    GrrrsFetched(Ok(grrrs)) -> #(
      Model(..model, grrrs: grrrs, loading: False),
      effect.none(),
    )

    GrrrsFetched(Error(err)) -> #(
      Model(..model, loading: False, errors: [format_http_error(err)]),
      effect.none(),
    )

    GrrrPosted(Ok(created)) -> #(
      Model(
        ..model,
        body: "",
        errors: [],
        submitting: False,
        grrrs: prepend_unique(model.grrrs, created),
      ),
      effect.none(),
    )

    GrrrPosted(Error(err)) -> #(
      Model(..model, submitting: False, errors: [format_http_error(err)]),
      effect.none(),
    )

    WsStatusChanged(connected) -> #(
      Model(..model, ws_connected: connected),
      effect.none(),
    )

    WsFrameReceived(raw) ->
      case json.parse(raw, ws_event_decoder()) {
        Ok(PresenceEvent(online:)) -> #(
          Model(..model, online: online),
          effect.none(),
        )
        Ok(GrrrCreatedEvent(grrr:)) -> #(
          Model(..model, grrrs: prepend_unique(model.grrrs, grrr)),
          effect.none(),
        )
        Error(_) -> #(model, effect.none())
      }
  }
}

fn prepend_unique(
  grrrs: List(PostedGrrr),
  item: PostedGrrr,
) -> List(PostedGrrr) {
  case list.any(grrrs, fn(g) { g.id == item.id }) {
    True -> grrrs
    False -> [item, ..grrrs]
  }
}

fn subscribe_timeline() -> Effect(Msg) {
  effect.from(fn(dispatch) {
    connect_timeline(
      "/ws/timeline",
      fn(connected) { dispatch(WsStatusChanged(connected)) },
      fn(frame) { dispatch(WsFrameReceived(frame)) },
    )
  })
}

fn fetch_grrrs() -> Effect(Msg) {
  let decoder =
    decode.field("grrrs", decode.list(grrr_decoder()), decode.success)
  rsvp.get("/api/grrrs", rsvp.expect_json(decoder, GrrrsFetched))
}

fn post_grrr(draft: DraftGrrr) -> Effect(Msg) {
  let payload =
    json.object([
      #("author", json.string(handle.to_string(draft.author))),
      #("body", json.string(post.to_string(draft.body))),
    ])
  let decoder = decode.field("grrr", grrr_decoder(), decode.success)
  rsvp.post("/api/grrrs", payload, rsvp.expect_json(decoder, GrrrPosted))
}

fn ws_event_decoder() -> decode.Decoder(WsEvent) {
  use kind <- decode.field("type", decode.string)
  case kind {
    "presence" -> {
      use online <- decode.field("online", decode.int)
      decode.success(PresenceEvent(online:))
    }
    "grrr_created" -> {
      use grrr <- decode.field("grrr", grrr_decoder())
      decode.success(GrrrCreatedEvent(grrr:))
    }
    _ -> decode.failure(PresenceEvent(online: 0), "WsEvent")
  }
}

fn grrr_decoder() -> decode.Decoder(PostedGrrr) {
  use id <- decode.field("id", decode.string)
  use author <- decode.field("author_handle", decode.string)
  use body <- decode.field("body", decode.string)
  use created_at <- decode.field("created_at", decode.string)
  decode.success(PostedGrrr(id:, author:, body:, created_at:))
}

fn view(model: Model) -> Element(Msg) {
  let remaining = post.max_body_length - string.length(string.trim(model.body))
  let counter_color = case remaining < 0 {
    True -> "text-[#f38ba8]"
    False -> "text-[#94e2d5]"
  }

  let presence_class = case model.ws_connected {
    True -> "border-[#94e2d5] text-[#94e2d5]"
    False -> "border-[#6c7086] text-[#a6adc8]"
  }

  let presence_text = case model.ws_connected {
    True -> "● " <> int.to_string(model.online) <> " online"
    False -> "○ reconnecting..."
  }

  div([class("min-h-screen bg-[#1e1e2e] text-[#cdd6f4] py-10 px-4 font-sans")], [
    div([class("max-w-2xl mx-auto space-y-6")], [
      header(
        [
          class(
            "flex items-center justify-between border-b border-[#45475a] pb-4 gap-3 flex-wrap",
          ),
        ],
        [
          h1([class("text-2xl font-extrabold text-[#cba6f7]")], [
            text("grrr · Lustre SPA"),
          ]),
          div([class("flex items-center gap-2")], [
            span(
              [
                class(
                  "rounded-full border bg-[#313244] px-3 py-1 text-xs font-mono "
                  <> presence_class,
                ),
              ],
              [text(presence_text)],
            ),
            span(
              [
                class(
                  "rounded-full border border-[#89b4fa] bg-[#313244] px-3 py-1 text-xs font-mono",
                ),
              ],
              [
                text(int.to_string(list.length(model.grrrs)) <> " grrrs"),
              ],
            ),
          ]),
        ],
      ),
      form(
        [
          event.on_submit(fn(_) { Submitted }),
          class("rounded-xl border border-[#45475a] bg-[#181825] p-5 space-y-4"),
        ],
        [
          input([
            type_("text"),
            value(model.author),
            event.on_input(AuthorChanged),
            placeholder("@handle"),
            class(
              "w-full rounded-lg border border-[#45475a] bg-[#11111b] px-3 py-2 font-mono text-sm text-[#f5c2e7]",
            ),
          ]),
          textarea(
            [
              value(model.body),
              event.on_input(BodyChanged),
              placeholder("What's happening on the BEAM?"),
              class(
                "w-full rounded-lg border border-[#45475a] bg-[#11111b] px-3 py-2 text-sm",
              ),
            ],
            "",
          ),
          view_errors(model.errors),
          div([class("flex items-center justify-between")], [
            span([class("font-mono text-xs font-bold " <> counter_color)], [
              text(int.to_string(remaining) <> " chars left"),
            ]),
            button(
              [
                type_("submit"),
                disabled(model.submitting),
                class(
                  "rounded-lg bg-[#89b4fa] px-4 py-2 text-sm font-bold text-[#11111b] cursor-pointer disabled:opacity-50",
                ),
              ],
              [
                text(case model.submitting {
                  True -> "Posting..."
                  False -> "Post Grrr"
                }),
              ],
            ),
          ]),
        ],
      ),
      case model.loading {
        True ->
          p([class("text-sm text-[#a6adc8] font-mono")], [
            text("Loading grrrs from Glimr..."),
          ])
        False -> div([class("space-y-3")], list.map(model.grrrs, view_grrr))
      },
    ]),
  ])
}

fn view_errors(errors: List(String)) -> Element(Msg) {
  case errors {
    [] -> element.none()
    _ ->
      ul(
        [
          class(
            "rounded-lg border border-[#f38ba8] bg-[#f38ba8]/10 p-3 text-xs text-[#f38ba8] list-disc pl-6",
          ),
        ],
        list.map(errors, fn(err) { li([], [text(err)]) }),
      )
  }
}

fn view_grrr(item: PostedGrrr) -> Element(Msg) {
  div([class("rounded-xl border border-[#45475a] bg-[#181825] p-4")], [
    div([class("flex items-center justify-between text-xs")], [
      span([class("font-mono text-sm font-bold text-[#f5c2e7]")], [
        text(item.author),
      ]),
      span([class("font-mono text-[#a6adc8]")], [text(item.created_at)]),
    ]),
    p([class("mt-1 text-[#cdd6f4]")], [text(item.body)]),
  ])
}

fn format_error(err: DraftError) -> String {
  case err {
    InvalidHandle(handle.TooShort(_, min)) ->
      "Handle must be at least " <> int.to_string(min) <> " chars"
    InvalidHandle(handle.TooLong(_, max)) ->
      "Handle must be at most " <> int.to_string(max) <> " chars"
    InvalidHandle(handle.InvalidChars) ->
      "Handle may only use letters, numbers, and underscores"
    InvalidBody(Empty) -> "Grrr body cannot be empty"
    InvalidBody(TooLong(len, max)) ->
      "Too long: " <> int.to_string(len) <> "/" <> int.to_string(max)
  }
}

fn format_http_error(err: rsvp.Error(String)) -> String {
  case err {
    rsvp.NetworkError -> "Network error: is Glimr running on port 4567?"
    rsvp.HttpError(resp) ->
      "Server returned HTTP " <> int.to_string(resp.status)
    rsvp.JsonError(_) -> "Could not decode JSON response from server"
    rsvp.UnhandledResponse(resp) ->
      "Unexpected response (status " <> int.to_string(resp.status) <> ")"
    rsvp.BadUrl(url) -> "Invalid URL: " <> url
    rsvp.BadBody -> "Invalid HTTP response body"
  }
}
