#!/usr/bin/env bash
# Verification gate for `grrr` lessons.
# Invoked automatically by `.config/wt.toml` [pre-merge] or manually before closing a lesson.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "==> Verifying worktree: $ROOT"

if [[ -f "$ROOT/shared/gleam.toml" ]]; then
  echo "  + shared: gleam format --check"
  (cd "$ROOT/shared" && gleam format --check src test)
  echo "  + shared: gleam test (BEAM)"
  (cd "$ROOT/shared" && gleam test)
  if command -v bun >/dev/null 2>&1; then
    echo "  + shared: gleam test --target javascript --runtime bun"
    (cd "$ROOT/shared" && gleam test --target javascript --runtime bun)
  elif command -v node >/dev/null 2>&1; then
    echo "  + shared: gleam test --target javascript --runtime node"
    (cd "$ROOT/shared" && gleam test --target javascript --runtime node)
  fi
fi

if [[ -f "$ROOT/server/gleam.toml" ]]; then
  echo "  + server: gleam deps download, check & test"
  (cd "$ROOT/server" && gleam deps download && gleam check && gleam test)
fi

if [[ -f "$ROOT/client/gleam.toml" ]]; then
  echo "  + client: gleam deps download & build --target javascript"
  (cd "$ROOT/client" && gleam deps download && gleam build --target javascript)
fi

echo "==> All checks passed!"
