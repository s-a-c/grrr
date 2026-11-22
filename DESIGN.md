---
colors:
  mocha:
    base: "#1e1e2e"
    mantle: "#181825"
    crust: "#11111b"
    surface0: "#313244"
    surface1: "#45475a"
    surface2: "#585b70"
    border-ui: "#6c7086"
    text: "#cdd6f4"
    subtext1: "#c5cde9"
    subtext0: "#b4bcd8"
    on-accent: "#11111b"
    gleam: "#f5c2e7"
    gleam-ink: "#f8d6ef"
    glimr: "#89b4fa"
    glimr-ink: "#a3c6ff"
    lustre: "#cba6f7"
    lustre-ink: "#dcc2fb"
    beam: "#94e2d5"
    beam-ink: "#aeece2"
    ok: "#a6e3a1"
    ok-ink: "#b8ebb4"
    warn: "#f9e2af"
    warn-ink: "#fcebc4"
    err: "#f38ba8"
    err-ink: "#f8a5bc"
    peach: "#fab387"
  latte:
    base: "#eff1f5"
    mantle: "#e6e9ef"
    crust: "#dce0e8"
    surface0: "#ccd0da"
    surface1: "#bcc0cc"
    surface2: "#9ca0b0"
    border-ui: "#6c6f85"
    text: "#1e2030"
    subtext1: "#313449"
    subtext0: "#43465c"
    on-accent: "#eff1f5"
    gleam: "#a61e8c"
    gleam-ink: "#84146f"
    glimr: "#1750c4"
    glimr-ink: "#113d99"
    lustre: "#6c26d4"
    lustre-ink: "#5319ab"
    beam: "#0c6b70"
    beam-ink: "#085155"
    ok: "#1f6b13"
    ok-ink: "#15500c"
    warn: "#8a5600"
    warn-ink: "#6b4200"
    err: "#b80d38"
    err-ink: "#94072a"
    peach: "#b34000"
motion:
  ease-out: "cubic-bezier(0.22, 1, 0.36, 1)"
  ease-expo: "cubic-bezier(0.16, 1, 0.3, 1)"
  dur-micro: "140ms"
  dur-short: "260ms"
  dur-med: "480ms"
name: grrr — Catppuccin Machine Room Design System
rounded:
  sm: "8px"
  md: "12px"
  lg: "16px"
  pill: "999px"
spacing:
  unit: "4px"
  xs: "0.25rem"
  sm: "0.5rem"
  md: "1rem"
  lg: "1.5rem"
  xl: "2.25rem"
  topbar-height: "62px"
  page-max-width: "72rem"
spec: "google-labs-code/design.md"
themes:
  dark: "Catppuccin Mocha (WCAG 2.1 AA High-Contrast)"
  light: "Catppuccin Latte (WCAG 2.1 AA High-Contrast)"
typography:
  ui: '-apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, "Helvetica Neue", Arial, sans-serif'
  display: '-apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, "Helvetica Neue", Arial, sans-serif'
  mono: '"JetBrains Mono", ui-monospace, "SF Mono", SFMono-Regular, Menlo, Consolas, monospace'
  body-md:
    fontSize: "16.5px"
    lineHeight: 1.65
    measure: "70ch"
  h1:
    fontSize: "clamp(2rem, 4vw, 3rem)"
    fontWeight: 850
    lineHeight: 1.08
    letterSpacing: "-0.02em"
  h2:
    fontSize: "clamp(1.45rem, 2.6vw, 1.95rem)"
    fontWeight: 820
    letterSpacing: "-0.02em"
version: "1.0.0"
---

# `grrr` Design System (`DESIGN.md`)

## Overview

`grrr` is a full-stack typed functional social platform (Twitter clone) built with **Gleam**, **Glimr** (+ Loom templates for the admin portal), **Lustre** (MVU SPA + optional admin islands), and **BEAM/OTP** (live timeline & online presence).

The visual identity follows a **Catppuccin Machine Room** aesthetic: high-craft, atmospheric, tactile, and instrument-grade. Every visual choice serves comprehension and direct feedback:

- **Invariant domain hues** map each architectural layer (`shared/` Gleam core, `Glimr` server, `Lustre` SPA, `BEAM` live actors) to one consistent Catppuccin color across diagrams, cards, badges, timelines, and interactive widgets.
- **Accessible by default**: strict **WCAG 2.1 AA** contrast ratios (≥ 4.5:1 for text, ≥ 3:1 for UI borders) in both **Catppuccin Latte** (light) and **Catppuccin Mocha** (dark), paired with user-selectable controls for **Theme** (`Latte / Auto / Mocha`), **Glow**, **Motion**, and **Web Audio SFX**.
- **Tactile & alive**: 3D perspective stages, pointer-tilt cards with dynamic specular sheen, animated SVG data-flow diagrams, and subtle synthesized Web Audio chimes make architectural state changes immediately perceptible.

This `DESIGN.md` governs both the interactive course workspace (`lessons/`, `reference/`, `assets/`) and the upcoming `grrr` web applications (Loom admin portal and Lustre SPA).

## Colors

Every surface and semantic token is defined in dual palettes (`html[data-theme="mocha"]` and `html[data-theme="latte"]`) in `assets/lesson.css`, persisted via `localStorage` (`grrr-course-prefs-v1`), and resolved before first paint to prevent theme flash.

### Surface Hierarchy

- **Base (`--base`):** Page canvas with subtle dot-grid texture (`24px` pitch) and two soft atmospheric corner blooms (`--bloom-a`, `--bloom-b`) when Glow is enabled.
- **Mantle (`--mantle`):** Primary elevated container surface for instrument panels, tilt cards, tables, and timeline cards.
- **Crust (`--crust`):** Deep inset surface for code blocks, SVG canvases, form inputs, and telemetry tiles.
- **Surface 0 / 1 / 2 (`--surface0`, `--surface1`, `--surface2`):** Interactive control fills, hover states, and subtle dividers.
- **UI Border (`--border-ui`):** High-contrast structural stroke meeting ≥ 3:1 non-text contrast against `--base`.

### Invariant Domain & Semantic Accents

Each accent provides four coordinated tokens: base (`--x`), high-contrast text ink (`--x-ink`), translucent fill (`--x-tint`), and toggleable luminous shadow (`--x-glow`).

- **Gleam / `shared/` Core (`--gleam`):** Pink/plum (`#f5c2e7` Mocha / `#a61e8c` Latte) — pure domain types, opaque constructors, shared codecs.
- **Glimr + Loom Server (`--glimr`):** Sapphire blue (`#89b4fa` Mocha / `#1750c4` Latte) — HTTP routing, Loom admin templates, JSON API, primary CTAs.
- **Lustre SPA (`--lustre`):** Mauve/violet (`#cba6f7` Mocha / `#6c26d4` Latte) — client MVU state, SPA components, active toggle indicators.
- **BEAM / OTP Live (`--beam`):** Teal (`#94e2d5` Mocha / `#0c6b70` Latte) — actors, WebSockets, PubSub, online presence indicators.
- **Status Channels:** `--ok` (green: `Ok(a)`, passing tests, mastery), `--warn` (amber: character limit warning, caution), `--err` (red/crimson: `Error(e)`, validation failure, opaque-type block).

## Typography

- **UI & Display (`--font-ui`, `--font-display`):** Native system sans-serif stack for instant zero-network rendering, crisp legibility, and tight negative tracking (`-0.02em`) on headings.
- **Monospace (`--font-mono`):** `JetBrains Mono` falling back to `SF Mono` / `ui-monospace` for all Gleam code, type signatures, `Result` outputs, character counters, and telemetry metrics.
- **Scale & Readability:**
  - Body text: `16.5px`, `1.65` line-height, capped at `70ch` measure (`--subtext1` on `--base`).
  - Page `h1`: `clamp(2rem, 4vw, 3rem)`, weight `850`, `1.08` line-height.
  - Section `h2`: `clamp(1.45rem, 2.6vw, 1.95rem)`, weight `820`, bottom hairline divider.
  - Numeric readouts (character counts, mastery scores, timeline counters) use tabular numerals (`font-variant-numeric: tabular-nums`) to prevent layout jitter.

## Layout

- **Container:** Centered `.page` shell with `max-width: 72rem` and generous horizontal padding (`1.25rem`).
- **Top Instrument Bar (`.topbar`):** Sticky (`62px` min-height), translucent frosted backdrop (`backdrop-filter: blur(14px)`), housing brand emblem, navigation links, live mastery progress pill, and user preference controls (`Latte / Auto / Mocha`, `Glow`, `Motion`, `Audio`).
- **Scroll Progress Indicator:** Fixed `3px` top gradient bar (`--gleam` → `--glimr` → `--lustre`) tracking reading progress.
- **Responsive Grids:**
  - Hero split: 1-column mobile → 2-column `11fr / 11fr` desktop (`≥ 980px`) pairing prose with a 3D interactive stage.
  - Card & comparison grids: `repeat(auto-fit, minmax(240px, 1fr))` for tilt cards and `minmax(300px, 1fr)` for Laravel-vs-Gleam side-by-side comparisons.
- **Print Layout (`@media print`):** Strips chrome (`.topbar`, toolbars, copy/reset buttons), switches to clean ink-on-white, removes glows, and prevents card splits (`break-inside: avoid`) so reference sheets print cleanly.

## Elevation and Depth

Depth is communicated through **surface luminance stepping**, **3D CSS perspective**, and **user-toggleable luminous glows** rather than generic flat grey drop shadows:

- **Layer 0 (`--base`):** Background canvas with dot grid and atmospheric blooms.
- **Layer 1 (`--mantle` + `--shadow-sm`):** Cards, instrument panels, and tables.
- **Layer 2 (`--crust`):** Recessed wells for code editors, SVG stages, and inputs.
- **3D Interactive Depth:**
  - **Tilt Cards (`.tilt-card`):** `perspective(920px)` dynamic pointer-tracked `rotateX`/`rotateY` (`±7deg`) with a cursor-following radial specular sheen (`.tilt-sheen`).
  - **3D Orbital Stage (`.orbit-shell`):** `perspective: 1050px` interactive scene with a 6-face CSS 3D cube prism (`.prism-core`) and depth-sorted orbiting nodes (`scale` and `opacity` driven by projected `z` coordinate).
- **Glow Channel (`data-glow="on|off"`):** Colored outer glows (`0 0 22px var(--tc-glow)`) reinforce domain identity and active focus; setting `data-glow="off"` cleanly zeroes every glow token and bloom.

## Shapes

Consistent geometric rounding softens technical density while preserving crisp instrument edges:

- **Small (`--radius-sm: 8px`):** Buttons, segmented controls, code copy chips, quiz options, inputs, metric tiles.
- **Medium (`--radius-md: 12px`):** Code blocks (`pre`), comparison cards, step cards, quiz cards, SVG canvases.
- **Large (`--radius-lg: 16px`):** Hero 3D orbital stage, 3D tilt cards, interactive simulator instrument panels.
- **Pill (`--radius-pill: 999px`):** Domain badges (`.domain-badge`), mastery progress pill, presence status dots.

## Components

All reusable course components live in `assets/` (`lesson.css`, `ui.js`, `quiz.js`) and serve as the visual blueprint for `grrr`'s Loom admin and Lustre SPA components:

- **Top Instrument Bar (`.topbar`):** Houses segmented theme selector (`data-scheme-btn`), `aria-pressed` toggles (`Glow`, `Motion`, `Audio`), and live `.mastery-pill`. Keyboard shortcuts: `t` (theme), `g` (glow), `m` (audio).
- **3D Orbital Constellation (`GrrrOrbit.mount`):** Interactive drag + keyboard-arrow 3D stage with Pause/Reset controls and animated dashed SVG constellation edges.
- **3D Domain Tilt Cards (`.tilt-card`):** Accent-bordered cards with spinning SVG emblem rings (`.spin-ring`), specular sheen, and domain-specific Web Audio chimes (`gleam`, `glimr`, `lustre`, `beam`).
- **Interactive SVG Simulators (`.instrument`):** Combines preset pills, live text/control input, an animated glowing SVG packet canvas (`feGaussianBlur` filter + `requestAnimationFrame` easing), 4-column telemetry metrics, and a live `aria-live="polite"` result banner (`is-ok` / `is-err`).
- **Hands-On Lab Steps (`.steps`) & Code Blocks (`pre`):** Numbered glowing step badges paired with auto-injected one-click `.copy-btn` controls.
- **Retrieval Quiz (`.quiz-pool` / `.quiz-card`):** Randomized subset of `3–7` questions drawn from a `7–13` question pool on every page load and Reset Quiz click (with shuffled equal-word-count options), immediate feedback, mastery bar sync, and synthesized `pass` / `fail` / `win` Web Audio cues.
- **Web Audio Synth (`window.GrrrSFX`):** Pure zero-dependency Web Audio API engine (lazy `AudioContext` created only after user gesture; muteable anytime).

## Do's and Don'ts

- **Do:** Keep every text/background pair ≥ 4.5:1 and every UI border ≥ 3:1 across **both** Catppuccin Latte and Catppuccin Mocha.
- **Do:** Respect `prefers-reduced-motion: reduce` and the `data-motion="off"` toggle by halting CSS keyframe loops, pointer tilts, and `requestAnimationFrame` orbits immediately.
- **Do:** Lock each technology to its invariant hue (`gleam`, `glimr`, `lustre`, `beam`) so learners and users recognize system boundaries at a glance.
- **Do:** Keep `AudioContext` unallocated until user interaction and make every sound subtle, short (`40–160ms`), and muteable.
- **Do:** Build reusable visual components in `assets/` (and later shared Lustre/Loom component modules) rather than duplicating inline CSS or JS across pages.
- **Don't:** Use raw hex colors inside HTML pages or components — always reference semantic Catppuccin CSS custom properties (`var(--mantle)`, `var(--gleam-ink)`, etc.).
- **Don't:** Rely on color alone to convey `Ok` vs `Error` state; always pair color with explicit labels, icons, or typed signatures (`Ok(...)` / `Error(...)`).
- **Don't:** Break printability on reference sheets (`reference/*.html`) with dark backgrounds or unclipped 3D transforms.
- **Don't:** Give away quiz answers through option length, formatting, or repeated answer positions.
