# Teaching Notes & User Preferences

- **Pacing:** 10–15 minute bites, hands-on, one tangible win per lesson.
- **UI & Visual Aesthetic (applies to every lesson and reference page):**
  - High-contrast **WCAG 2.1 AA** compliant **Catppuccin Latte (light) / Catppuccin Mocha (dark)** theme with user-selectable Light / Dark / System switcher (persisted in `localStorage`), plus Glow, Motion, and Audio toggles.
  - **Highly animated & interactive:** 3D orbital stages, 3D pointer-tilt cards with dynamic specular sheen, glow effects, animated SVGs (flowing data packets, interactive state-gate simulators), scroll reveals, and synthesized Web Audio sound effects (`assets/ui.js`, `assets/lesson.css`, `assets/quiz.js`).
  - Reference benchmark: `/Users/s-a-c/docs/superpowers/research/2026-11-12-typescript-effect-rescript-gleam-explainer-glm.html`.
- **Mental-model bridge:** Anchor new concepts to Laravel/Livewire and Laravel/React:
  - `Laravel` <-> `Glimr`
  - `Blade / Livewire` <-> `Loom` (plus noting Lustre Server Components where relevant)
  - `React / Vue` <-> `Lustre`
- **External links:** Always include primary docs links and pointers to community spaces (Gleam Discord / r/gleam) for wisdom. All external (`http://` / `https://`) links open in a new tab with `rel="noopener noreferrer"` (enforced globally by `assets/ui.js` + `a.ext-link` indicator).
- **Quick Retrieval Checks (`assets/quiz.js`):**
  - Author a question pool of **7–13** questions per lesson (`.quiz-pool` with `data-quiz-count` set between **3 and 7** based on lesson depth/length).
  - On page load **and** on **Reset Quiz**, randomly draw `N` questions from the pool and shuffle option order within each question.
  - Keep all 4 options within a question equal in word count with no formatting clues.
- **Architecture split for `grrr`:**
  - Admin portal: Glimr + Loom (with optional Lustre islands)
  - User app: Glimr JSON API + Lustre SPA
  - Live features: live timeline updates + online presence (BEAM/OTP)
- **Local toolchain:** Verified `gleam 1.19.2` and Erlang `OTP 29` on macOS.

- **Git & Worktree Workflow (authorized by user):**
  - Bare repo at `grrr/.bare` + 1-line `grrr/.git` redirect (`gitdir: ./.bare`) + sibling worktrees (`main/`, `lesson-0001/`, `lesson-0002/`, ...).
  - Agent is authorized to run lesson-boundary branch/worktree/commit/tag/push steps in this repo.
  - Branches: `lesson-NNNN` (kept permanently, fast-forward merged into `main`).
  - Tags: `checkpoint/lesson-NNNN` (annotated).
  - Paths in lessons: always use portable worktree-relative paths (`lesson-NNNN/` root, `cd shared`, `cd server`, `cd client`, `./scripts/verify-lesson.sh`) — never hardcode `/Users/s-a-c/...`.
  - See `docs/REPO-MANAGEMENT.md` and `.config/wt.toml`.
