# Changelog

All notable changes to the box skill are documented here.

**Note:** this skill folder is not a git repo. This changelog is the primary history mechanism — keep it current on every change.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [v1.2] — 2026-06-08

Driven by Stu's feedback after the first real use of the skill. Six changes, all aimed at discoverability and ergonomics.

### Added

- **`open [path]` verb** — explicit front door for resuming an existing box across sessions. Resolves the box root (explicit path, or most-recently-modified box), loads vocabulary, reads the README head, detects handoffs in `handoffs/`, and orients. Replaces the old `box is here: <path>` + `box status` incantation, which was undiscoverable. Protocol: `protocols/open.md`.
- **`handoff [text]` verb** — first-class carry-forward writer. Commits the current state, composes a standalone handoff document into `handoffs/`, appends a `handoff` Log event, and commits. Decoupled from `park`: `park` points to `protocols/handoff.md` as the canonical carry-forward form rather than re-implementing it. Use `handoff` when you want a carry-forward prompt without a new `F<id>`. Protocol: `protocols/handoff.md`.
- **`pickup [path]` verb** — box-aware resume from a handoff (defaults to the latest in `handoffs/`). Guarantees box vocabulary is loaded before acting on the brief — unlike the standalone `/pickup`, which is box-blind and cannot interpret `F<id>`, `Q<id>`, projected-zone markers, or `box plan` correctly. Protocol: `protocols/pickup.md`.

### Changed

- **`argument-hint` cleaned up** — now shows all verbs at a glance when you type `/box `: `new · open · status · plan · park · note · handoff · pickup · rollup · close`.
- **`plan` now uses native plan mode** for non-trivial planning (laying out the work track from scratch, substantially reshaping multiple items, or discovery-heavy scoping). The legacy `/create-plan` skill is explicitly NOT used — it predates native plan mode. Native plan mode inherits Stu's global planning conventions (fresh agents per logical phase, etc.) automatically. Light edits (add/reorder one item, flip a state) stay inline as before. On exit from plan mode, three doors are offered explicitly: action now / write into the box / discuss further — no auto-execution.
- **`allowed-tools` comment reworded** — previously flagged as "urgent: verify globs". Now correctly scoped: these only matter outside `bypassPermissions`/`acceptEdits` mode. In Stu's normal setup they are largely moot; they matter for default-permission runs, headless/cron contexts, and other users.

---

## [v1.1] — 2026-06-05

Refinements after the initial build, before first real use.

### Added

- **Q-IDs** (`Q1`, `Q2`, …) for open-question tracking, mirroring the `F<id>` pattern. Assigned by `note` when the type is `open-question`; never reused or renumbered. Authoritative source is `log/` filenames; the README projected zone is a lagging view.
- **`_None yet._` constant** — empty zones in the projected area use this literal string so `rollup` has a reliable sentinel to replace rather than leaving blank headings.

### Changed

- **`git -C` commit convention** — all git commands run with `git -C "$CONTEXT_REPO" …` against the resolved repo root. `cd` into `.context/` is never used (a command starting with `cd` cannot be pre-approved). Resolve once per invocation via `readlink -f .context` (or `greadlink -f` on older macOS).
- **Scoped `allowed-tools`** — git commands locked to the `git -C * …` forms that match the resolved-root pattern.
- **Log filename convention** — colons in event-type names render as hyphens in filenames (colons are a portability footgun). `question-resolved:Q3` → `…-question-resolved-Q3.md`; `followup-parked:F1` → `…-followup-parked-F1.md`. The hyphenated form is what `rollup` scans for.

---

## [v1.0] — 2026-06-04

Initial build. Validated against the `Lightning.Adaptors` rewrite research (a 7-week, 5-burst project, ~13k lines of artefacts across ~45 docs). Two research passes — a structural read of the artefacts folder and a fan-out over the interactive sessions — surfaced the load-bearing findings that shaped the design.

### Added

- **Five-word model**: Box / README / Plan / Follow-ups / Log. Drawn from artefacts Stu already hand-rolled.
- **Core verbs**: `new`, `status`, `plan`, `park`, `note`, `rollup`, `close`.
- **Stub → tome layout**: a freshly-born box is one README with the plan inline; structure accretes on demand; the format never restructures.
- **`park` as the headline gesture**: fuses follow-up capture with carry-forward handoff. Disposition-first (`in-scope-later` / `→ issue` / `→ new box` / `dropped`) — disposal language, not deferral.
- **Commit-before-edit convention** baked into every state-modifying verb.
- **Projected-zone markers** (`<!-- BOX: BEGIN PROJECTED -->` / `<!-- BOX: END PROJECTED -->`) so `rollup` is safe to re-run.
- **Follow-up IDs** (`F1`, `F2`, …) — never reused, never renumbered.
- **Discovery-before-commitment rule** for dispatched subagents.
- **Public-artefacts-never-leak-the-box rule** — no internal vocabulary crosses to a public surface.
