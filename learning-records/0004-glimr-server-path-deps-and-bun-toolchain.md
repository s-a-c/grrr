# Glimr Server Boot, Monorepo Path Dependencies & Bun Toolchain

Status: active

The learner scaffolded the `server/` Glimr application inside `lesson-0003/`, wired `shared = { path = "../shared" }` in `server/gleam.toml`, resolved stale template `manifest.toml` lockfile drift (`gleam_stdlib 0.71.0` -> `1.2.0`) via `gleam deps update`, configured Bun as the JS runtime (`[javascript] runtime = "bun"`, `bun --bun vite`, `deps:refresh`), and served live JSON from `GET /api/health` backed by opaque `Handle` + `GrrrBody` types.

## Evidence
- `GET http://127.0.0.1:4567/api/health` returned `200 OK` with `{"status":"ok","sample_author":"@grrr_bot","sample_body":"Glimr + shared/ is alive on BEAM! 🐻","max_body_length":280}`.
- `./scripts/verify-lesson.sh` passed (`shared/` BEAM + Bun JS `12 passed`, `server/` `gleam check` + `gleam test`, `bun run build` in 58ms).
- Learner diagnosed port/proxy behavior (`APP_PORT` vs `DEV_PROXY_PORT`) and stale lockfile conflicts.

## Implications
- Ready for **Lesson 0004**: defining the `grrrs` SQLite schema in Glimr, running automatic migrations, writing typed `.sql` queries (`insert_grrr`, `list_recent`), and wiring `GET /api/grrrs` + `POST /api/grrrs` backed by `shared/grrr/post.new_draft_all`.
