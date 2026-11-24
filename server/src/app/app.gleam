//// Application Type
////
//// Defines the app-specific state passed through the framework
//// context. Database pools, caches, and other shared resources
//// live here so controllers can access them via ctx.app.
////

import app/realtime/timeline_hub.{type HubMsg}
import gleam/erlang/process.{type Subject}
import glimr/cache.{type CachePool}
import glimr/db/db.{type DbPool}

pub type App {
  App(
    db: DbPool,
    cache: CachePool,
    hub: Subject(HubMsg),
  )
}
