//// Real-Time Timeline & Online Presence Hub (BEAM/OTP Actor)
////
//// Holds the list of currently connected WebSocket client Subjects.
//// Replaces external Redis PubSub + Laravel Reverb with one typed OTP actor.

import gleam/erlang/process.{type Subject}
import gleam/json
import gleam/list
import gleam/otp/actor

pub type HubMsg {
  Join(client: Subject(String))
  Leave(client: Subject(String))
  BroadcastGrrr(payload: String)
}

type State {
  State(clients: List(Subject(String)))
}

/// Start the global TimelineHub actor and return its typed Subject.
pub fn start() -> Subject(HubMsg) {
  let assert Ok(started) =
    actor.new(State(clients: []))
    |> actor.on_message(handle_message)
    |> actor.start()

  started.data
}

pub fn join(hub: Subject(HubMsg), client: Subject(String)) -> Nil {
  process.send(hub, Join(client))
}

pub fn leave(hub: Subject(HubMsg), client: Subject(String)) -> Nil {
  process.send(hub, Leave(client))
}

pub fn broadcast_grrr(hub: Subject(HubMsg), payload: String) -> Nil {
  process.send(hub, BroadcastGrrr(payload))
}

fn handle_message(state: State, msg: HubMsg) -> actor.Next(State, HubMsg) {
  case msg {
    Join(client) -> {
      let clients = [client, ..state.clients]
      broadcast_presence(clients)
      actor.continue(State(clients:))
    }

    Leave(client) -> {
      let clients = list.filter(state.clients, fn(c) { c != client })
      broadcast_presence(clients)
      actor.continue(State(clients:))
    }

    BroadcastGrrr(payload) -> {
      list.each(state.clients, fn(c) { process.send(c, payload) })
      actor.continue(state)
    }
  }
}

fn broadcast_presence(clients: List(Subject(String))) -> Nil {
  let frame =
    json.object([
      #("type", json.string("presence")),
      #("online", json.int(list.length(clients))),
    ])
    |> json.to_string()

  list.each(clients, fn(c) { process.send(c, frame) })
}
