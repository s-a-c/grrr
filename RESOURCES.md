# Gleam, Glimr, and Lustre Resources

## Knowledge

### Gleam & BEAM
- [Official Site: Gleam](https://gleam.run/)
  Canonical home for Gleam releases, installation, and ecosystem links. Use for: checking language updates and official announcements.
- [Interactive Guide: Gleam Language Tour](https://tour.gleam.run/)
  Official interactive reference covering types, opaque types, `Result`, `use` expressions, and externals. Use for: quick syntax refreshers and language-level guarantees.
- [HexDocs: `gleam_stdlib`](https://hexdocs.pm/gleam_stdlib/)
  Standard library documentation (`gleam/string`, `gleam/list`, `gleam/result`, `gleam/dict`, `gleam/option`). Use for: checking exact function signatures and edge cases.
- [HexDocs: `gleam_otp`](https://hexdocs.pm/gleam_otp/)
  Official OTP actor, supervisor, and process abstractions for Gleam on the BEAM. Use for: building live updates, PubSub, and presence processes in `grrr`.

### Glimr (Backend, Loom Templates, Auth, Migrations)
- [Official Docs: Glimr (`glimr.build`)](https://glimr.build/)
  Primary documentation for Glimr: routing, controllers, middleware, Loom templates, database migrations, sessions, and caching. Use for: all Glimr framework conventions and APIs.
- [GitHub: `glimr-org/glimr` (Starter Template & Docs)](https://github.com/glimr-org/glimr)
  Official application skeleton showing standard directory layout, CLI commands (`./glimr`), and configuration. Use for: scaffolding the `grrr` backend and admin portal.
- [GitHub: `glimr-org/framework`](https://github.com/glimr-org/framework)
  Core Glimr framework source code (built on Wisp). Use for: inspecting exact types or middleware internals when docs are brief.
- [GitHub: `glimr-org/glimr_auth`](https://github.com/glimr-org/glimr_auth)
  Session-based authentication layer with Argon2id password hashing for Glimr. Use for: `grrr` user accounts, login, and admin auth.

### Lustre (Frontend SPA, Islands, Server Components)
- [HexDocs: Lustre](https://hexdocs.pm/lustre/)
  Official API docs and quickstart guide covering Model-View-Update, effects (`lustre/effect`), HTML elements, and Server Components. Use for: building the `grrr` SPA and optional admin islands.
- [GitHub: `lustre-labs/lustre`](https://github.com/lustre-labs/lustre)
  Source repository, examples, and release notes for Lustre. Use for: checking idiomatic SPA structure, routing, and HTTP/WebSocket effect examples.

## Wisdom (Communities)
- [Gleam Discord Server](https://discord.gg/Fm8aMwZ)
  The main, active Gleam community with dedicated channels for help, web dev, Lustre, and ecosystem packages. Use for: architecture critiques, idiom checks, and real-world BEAM/Lustre troubleshooting.
- [r/gleam (Reddit)](https://www.reddit.com/r/gleam/)
  Community showcase and discussion board (including Glimr release threads and production experience reports). Use for: broader ecosystem context and release discussions.
- [Gleam Community Packages Index (`packages.gleam.run`)](https://packages.gleam.run/)
  Searchable directory of Gleam Hex packages. Use for: discovering well-maintained libraries (JSON codecs, WebSockets, SQLite/Postgres drivers).

## Gaps
- **Glimr + Lustre monorepo layout:** Verify the cleanest path-dependency setup in `gleam.toml` between `shared/`, `server/` (Glimr), and `client/` (Lustre) before Lesson 0003.
- **Glimr WebSocket / PubSub / Presence API:** Check current `glimr.build` and `glimr-org/framework` docs for built-in WebSocket/broadcast support versus wiring `mist` + `gleam_otp` directly when we reach the live-updates lessons.
