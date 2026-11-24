# Repository & Worktree Management (`grrr`)

This repository uses a **bare Git repository (`.bare/`) with sibling worktrees**, one per lesson, so you can diff any two lessons (`git diff lesson-0001..lesson-0002`), keep every lesson checkpoint runnable side-by-side, and never lose work when switching lessons.

## 1. Directory Layout

```text
grrr/
├── .bare/              # Bare Git repository (object store, refs, config)
├── .git                # 1-line gitfile redirect: "gitdir: ./.bare"
├── main/               # Worktree for `main` (always = latest completed lesson)
├── lesson-0001/        # Worktree for `lesson-0001` (tag: checkpoint/lesson-0001)
└── lesson-0002/        # Worktree for `lesson-0002` (tag: checkpoint/lesson-0002)
```

- **Branches:** `main`, `lesson-0001`, `lesson-0002`, … (linear, fast-forward merged into `main`).
- **Tags:** `checkpoint/lesson-0001`, `checkpoint/lesson-0002`, … (namespaced under `checkpoint/` so tags never collide with branch names).
- **Tracked project configs:**
  - `.gitignore` / `.gitattributes` (ignores `**/build/`, `**/.env`, local SQLite DBs; tracks `**/manifest.toml` and `**/.env.example`).
  - `.config/wt.toml` (shared [Worktrunk](https://worktrunk.dev) hooks: `[pre-start]` runs `./scripts/setup-worktree.sh`, `[pre-merge]` runs `./scripts/verify-lesson.sh`).

## 2. Cloning from Scratch (New Student Setup)

### Option A: Bare Repo + Sibling Worktrees (Recommended)

```bash
mkdir grrr && cd grrr
git clone --bare https://github.com/s-a-c/grrr.git .bare
printf 'gitdir: ./.bare\n' > .git

# Required on bare clones so `git fetch` populates origin/* tracking refs
git --git-dir=.bare config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
git --git-dir=.bare config fetch.prune true
git --git-dir=.bare config worktree.guessRemote true
git --git-dir=.bare config pull.ff only
git fetch origin

# Create the main worktree
git worktree add main main
cd main && ./scripts/setup-worktree.sh
```

### Option B: Standard Clone (Single Working Directory)

If you prefer a single working tree without worktrees, a regular clone works identically:

```bash
git clone https://github.com/s-a-c/grrr.git
cd grrr
git switch lesson-0001
./scripts/setup-worktree.sh
```

## 3. Daily Lesson Workflow

### With Worktrunk (`wt`)

Requires `~/.config/worktrunk/config.toml` configured for bare repos:

```toml
worktree-path = "{{ repo_path }}/../{{ branch | sanitize }}"
```

1. **Start Lesson `N` from `main`:**

   ```bash
   wt switch --create lesson-0003 main
   ```

   `.config/wt.toml` automatically runs `./scripts/setup-worktree.sh` (`gleam deps download`, `.env` seeding).

2. **Verify Lesson `N`:**

   ```bash
   ./scripts/verify-lesson.sh
   ```

3. **Complete Lesson `N`, fast-forward `main`, and tag:**

   ```bash
   git add -A
   git commit -m "feat(lesson-0003): complete <topic>"
   git -C ../main merge --ff-only lesson-0003
   git tag -a checkpoint/lesson-0003 -m "Lesson 0003 completed"
   git push origin main lesson-0003 checkpoint/lesson-0003
   ```

   > **Note:** If your global `wt` config sets `[merge] remove = true` or `squash = true`, prefer `git -C ../main merge --ff-only lesson-NNNN` (or `wt merge --no-remove --no-squash`) so every lesson worktree and commit stays intact.

### Manual Pure-`git` Workflow (No Worktrunk Required)

1. **Start Lesson `N` from `main`:**

   ```bash
   cd /path/to/grrr
   git worktree add lesson-0003 -b lesson-0003 main
   cd lesson-0003
   ./scripts/setup-worktree.sh
   ```

2. **Work through the lesson and verify:**

   ```bash
   ./scripts/verify-lesson.sh
   ```

3. **Commit, fast-forward `main`, tag, and push:**

   ```bash
   git add -A
   git commit -m "feat(lesson-0003): complete <topic>"
   git -C ../main merge --ff-only lesson-0003
   git tag -a checkpoint/lesson-0003 -m "Lesson 0003 completed"
   git push origin main lesson-0003 checkpoint/lesson-0003
   ```

## 4. Per-Worktree Setup Notes

- **`shared/`:** `gleam deps download` pulls from the global Hex cache; `shared/build/` stays local per worktree.
- **`server/` (Glimr, Lesson 0003+):** `setup-worktree.sh` copies `.env.example` → `.env` when absent. Keep each worktree's SQLite file inside its own worktree directory (and override `PORT` in `.env` if running two lessons simultaneously).
- **`client/` (Lustre SPA):** `gleam deps download` (+ `pnpm install` if JS tooling is present).
