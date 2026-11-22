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
  if command -v node >/dev/null 2>&1; then
    echo "  + shared: gleam test --target javascript"
    (cd "$ROOT/shared" && gleam test --target javascript)
  fi
fi

if [[ -f "$ROOT/server/gleam.toml" ]]; then
  echo "  + server: gleam format --check & gleam test"
  (cd "$ROOT/server" && gleam format --check src test && gleam test)
fi

if [[ -f "$ROOT/client/gleam.toml" ]]; then
  echo "  + client: gleam format --check & gleam build --target javascript"
  (cd "$ROOT/client" && gleam format --check src test && gleam build --target javascript)
fi

echo "==> All checks passed!"
