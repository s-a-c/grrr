# Hybrid UUIDv7 Schema, Auto-Migrations & Typed SQL Repositories

Status: active

The learner defined the `grrrs` table in Glimr using the Hybrid ID pattern (`schema.id()` internal integer PK + `schema.uuid("uuid")` with `schema.unique(["uuid"])` for public UUIDv7 APIs), added a custom `queries/list_recent.sql` query, generated and applied the SQLite migration and typed `gen/grrr.gleam` repository via `./glimr db_gen --migrate`, and exposed `GET /api/grrrs` using `use grrrs <- grrr.list_recent_or_fail(ctx.app.db)`.

## Evidence
- `lesson-0004/server/src/database/main/models/grrr/grrr_schema.gleam`, `queries/list_recent.sql`, `gen/grrr.gleam`, `_migrations/20261122235828_migration.sql`, and `src/app/http/controllers/grrr_controller.gleam` compile cleanly and pass `./scripts/verify-lesson.sh` (`shared/` BEAM + Bun JS `12 passed`, `server/` `gleam check` + `gleam test`).

## Implications
- Ready for **Lesson 0005**: adding `youid` for UUIDv7 generation, building `POST /api/grrrs` with JSON decoding + `shared/grrr/post.new_draft_all` returning structured `422` errors, and rendering the first Loom Admin Portal timeline page.
