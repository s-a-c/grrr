#!/usr/bin/env bash
# Idempotent per-worktree bootstrap for `grrr` (Gleam + Glimr + Lustre).
# Invoked automatically by `.config/wt.toml` [post-create] or manually after `git worktree add`.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "==> Setting up worktree: $ROOT"

# 1. Seed per-worktree .env files from .env.example (never overwrites existing .env)
for dir in "$ROOT" "$ROOT/server" "$ROOT/client"; do
  if [[ -f "$dir/.env.example" && ! -f "$dir/.env" ]]; then
    /bin/cp "$dir/.env.example" "$dir/.env"
    echo "  + Created ${dir#"$ROOT"/}/.env from .env.example"
  fi
done

# 2. Download Gleam dependencies for each present package (uses shared global Hex cache)
for pkg in shared server client; do
  if [[ -f "$ROOT/$pkg/gleam.toml" ]]; then
    echo "  + gleam deps download ($pkg)"
    (cd "$ROOT/$pkg" && gleam deps download)
  fi
done

# 3. Install JS dependencies if client/ uses pnpm
if [[ -f "$ROOT/client/package.json" ]] && command -v pnpm >/dev/null 2>&1; then
  echo "  + pnpm install (client)"
  (cd "$ROOT/client" && pnpm install --frozen-lockfile || pnpm install)
fi

echo "==> Worktree ready: $ROOT"
