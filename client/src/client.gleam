import gleam/int
import gleam/list
import gleam/string
import grrr/handle
import grrr/post.{type DraftError, Empty, InvalidBody, InvalidHandle, TooLong}
import lustre
import lustre/attribute.{class, placeholder, type_, value}
import lustre/element.{type Element, text}
import lustre/element/html.{
  button, div, form, h1, header, input, li, p, span, textarea, ul,
}
import lustre/event

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

pub type PostedGrrr {
  PostedGrrr(author: String, body: String)
}

pub type Model {
  Model(
    author: String,
    body: String,
    errors: List(String),
    grrrs: List(PostedGrrr),
  )
}

pub type Msg {
  AuthorChanged(String)
  BodyChanged(String)
  Submitted
}

fn init(_flags) -> Model {
  Model(author: "@bear_dev", body: "", errors: [], grrrs: [])
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    AuthorChanged(author) -> Model(..model, author: author, errors: [])
    BodyChanged(body) -> Model(..model, body: body, errors: [])
    Submitted ->
      case post.new_draft_all(model.author, model.body) {
        Error(errs) -> Model(..model, errors: list.map(errs, format_error))

        Ok(draft) -> {
          let new_post =
            PostedGrrr(
              author: handle.to_string(draft.author),
              body: post.to_string(draft.body),
            )
          Model(..model, body: "", errors: [], grrrs: [new_post, ..model.grrrs])
        }
      }
  }
}

fn view(model: Model) -> Element(Msg) {
  let remaining = post.max_body_length - string.length(string.trim(model.body))
  let counter_color = case remaining < 0 {
    True -> "text-[#f38ba8]"
    False -> "text-[#94e2d5]"
  }

  div([class("min-h-screen bg-[#1e1e2e] text-[#cdd6f4] py-10 px-4 font-sans")], [
    div([class("max-w-2xl mx-auto space-y-6")], [
      header(
        [
          class(
            "flex items-center justify-between border-b border-[#45475a] pb-4",
          ),
        ],
        [
          h1([class("text-2xl font-extrabold text-[#cba6f7]")], [
            text("grrr · Lustre SPA"),
          ]),
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
                class(
                  "rounded-lg bg-[#89b4fa] px-4 py-2 text-sm font-bold text-[#11111b] cursor-pointer",
                ),
              ],
              [
                text("Post Grrr"),
              ],
            ),
          ]),
        ],
      ),
      div([class("space-y-3")], list.map(model.grrrs, view_grrr)),
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
    p([class("font-mono text-sm font-bold text-[#f5c2e7]")], [text(item.author)]),
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
