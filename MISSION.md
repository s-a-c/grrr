# Mission: Production Typed Functional Web Dev with Gleam, Glimr, and Lustre (`grrr`)

## Why

Evaluate and master typed functional web development on the BEAM for production by building a realistic Twitter clone (`grrr`) from scratch. Bridge an existing Laravel/Livewire and Laravel/React mental model into Gleam's ecosystem (`Laravel <-> Glimr`, `Blade/Livewire <-> Loom`, `React/Vue <-> Lustre`) so I can confidently architect, build, and reason about real-time, fault-tolerant full-stack Gleam applications.

## Success Looks Like

- Build and run `grrr` with accounts/auth, posting "grrrs", a home timeline, likes, replies, follows, live updates, and online presence.
- Run a **Glimr** server that serves both:
  - an **admin portal** rendered with **Loom** templates (plus optional Lustre islands), and
  - a **JSON API** (plus real-time channel/WebSocket layer) powering a **Lustre SPA** for the user-facing app.
- Share Gleam domain types cleanly across the Erlang/BEAM backend and JavaScript/Lustre frontend.
- Explain and apply BEAM concurrency primitives (actors, PubSub, presence) and typed functional patterns (opaque types, `Result`, Model-View-Update) without leaning on trial-and-error.

## Constraints

- **10–15 minute bites:** short, focused, hands-on lessons with one tangible win each.
- **Visual-first:** copious diagrams, flowcharts, and Laravel-to-Gleam comparison tables.
- **Grounded in primary sources:** every lesson links to official docs and points to community spaces (Discord/forums) for real-world wisdom.
- **Local environment:** `gleam 1.19.2` and Erlang `OTP 29` are already installed.

## Out of Scope

- Introductory programming basics or Gleam syntax already covered in Exercism tutorials (unless a subtle edge case arises).
- Cloud deployment, Kubernetes, or DevOps pipelines until `grrr` runs end-to-end locally.
- CSS framework deep-dives (keep styling minimal and clean so focus stays on Gleam, Glimr, Lustre, and BEAM).
