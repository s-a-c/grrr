# Write Path: JSON Decoding, ISO-8601 Timestamps, UUIDv7 & 422 Error Bags

Status: active

The learner completed the end-to-end `POST /api/grrrs` write path in `lesson-0005/`: migrating `grrrs` from `unix_timestamps()` to `schema.timestamps()` via Glimr's snapshot-diffed auto-migration (`20261123055256_migration.sql`), decoding JSON via `wisp.require_json` + `gleam/dynamic/decode`, validating all fields at once with `shared/grrr/post.new_draft_all` (returning `422` error bags), stamping RFC 9562 UUIDv7 IDs (`youid/uuid.v7_string()`) and RFC 3339 UTC timestamps (`gleam/time/timestamp`), and persisting via `grrr.create_or_fail`.

## Evidence

- `./scripts/verify-lesson.sh` passed (`shared/` BEAM + Bun JS `12 passed`, `server/` `gleam check` + `gleam test` `1 passed`).
- Learner also uncovered and resolved a Glimr SQL codegen quirk: omitting trailing `;` in `queries/*.sql` after `RETURNING *`.

## Implications

- Ready for **Lesson 0006**: building the **Loom Admin Portal** (`/admin/grrrs`) using Glimr's Blade-inspired `.loom.html` templates, components, and Catppuccin styling from `DESIGN.md`.
