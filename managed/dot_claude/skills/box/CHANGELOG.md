# Changelog

All notable changes to the box skill are documented here.

**Note:** this skill folder is not a git repo. This changelog is the primary history mechanism — keep it current on every change.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [v2.0] — 2026-06-12

Prose and structure rewrite, from an audit of the v1.1-era text. No behaviour change: verbs, routing, file layouts, state machine, ID rules, commit conventions, the plan-vs-execute boundary, and the public-leak rule are all preserved. A backup of the pre-rewrite skill lives at `~/.claude-personal/skill-backups/box-v1.1-2026-06-12` (outside `skills/` so it doesn't register as a skill).

### Changed

- **SKILL.md slimmed to a router — roughly half its previous size** (~6.9k → ~4.2k tokens). Deleted "Resolved design decisions" (history now lives in README/CHANGELOG) and "Pickup ergonomics" (covered by `open.md`/`pickup.md`/`status.md`). The verb table's Purpose column is now one short sentence per verb; the protocol file is the spec.
- **Shared conventions stated once.** Each cross-cutting rule (commit contract, public-leak rule, projected-zone markers, optional spec, permanent IDs, box-native composition, discovery-before-commitment, the three-door offer, plan-vs-execute boundary, and others) now has a single canonical statement in SKILL.md's Conventions; protocols point to it instead of restating. Protocol `## Notes` sections that re-summarised their own steps were deleted.
- **Full de-jargoning pass across SKILL.md, all protocols, and all templates.** The figurative register (gate/graduate/promote/demote/hydrate/mint/fuse/tome/spine/eject/death-banner/"load-bearing" and the rest) is rewritten in plain English. Genuine structure names — track, projected zone, disposition, readiness checklist — are kept and defined once in SKILL.md's Vocabulary. The follow-up template field "Load-bearing facts" is renamed "Key facts". The Style rule stands: skill vocabulary stays in artefacts; conversational output is plain English.
- **Frontmatter `description` rewritten** to a plain trigger description (it loads into every session of every project).
- **Log event-type list moved** from SKILL.md to `protocols/rollup.md` (the only verb that scans all of them); SKILL.md keeps a one-line pointer.
- **README.md** updated to match: same de-jargoning, restatements of SKILL.md removed, design history retained.

### Fixed

Five consistency bugs:

1. SKILL.md's item-state table now includes `superseded` (previously only in `plan.md`/`templates/plan-item.md`).
2. `do.md` no longer treats a `ready` item with no `plan.md` as possibly legitimate: `ready` requires a `plan.md` (thin is fine); a ready item without one is an inconsistency to surface, not a legal state.
3. `plan.md`'s item-id example ("i3") corrected to the `D1`/`1`/`2` convention.
4. `status.md` now names the projected zone as the source of truth for the open-question count (its windowed log-filename scan can miss resolutions).
5. SKILL.md's subagent sentence corrected to include `import`: "most verbs run inline; `spec`, `do`, and `import` may dispatch subagents".

Post-rewrite verification pass fixed six more: `plan`'s track-edit modes regained the box-root resolution step; `plan next` now skips `superseded` as well as `done`; "head" defined in the Vocabulary; `close` now archives `superseded` item bodies (with banner + `superseded_by:`) alongside done ones; the `superseded:` event definition covers both docs and items; the commit-contract verb list includes `handoff` (and notes `import`'s per-phase commits); the routing inferences for `handoff`/`pickup`/`migrate` and the disposition glosses were restored; the `log/` layout comment corrected (`new` writes the first event).

---

## [v1.3.2] — 2026-06-11

The `import` protocol, promoted. `import` (bring a body of work that predates the box into a well-formed box) had existed as a detailed but unwired draft, written in pre-v1.3 vocabulary — a single inline "Plan" split to `plan.md`, a monolithic `follow-ups.md`. Rewritten to the v1.3 item model and wired into the verb table.

### Added

- **`import` verb** — now in the SKILL.md verb table and `argument-hint`. Bring a pre-existing corpus (scattered docs, a plan, findings, git history, a memory file) into a box **born mature** without breaking invariants: inventory by role → reconcile stale state → seed (`new`) → lay the track and items → replay findings/decisions (`note`) → assign Q/F ids (`note`/`park`) → reference-vs-archive → project the head (`rollup`) → report and stop. Composes existing verbs; introduces no new state. Protocol: `protocols/import.md`. (`import.md` is now chezmoi-tracked — it had never been added.)

### Changed

- **`import.md` rewritten to `box_schema: 1.3`** — the unit of work is the **item** (`items/<id>/` with `spec.md`/`plan.md`), the README is a projected **track** over items (no inline plan body, ever), follow-ups are `follow-ups/F<n>.md` (folder, not a monolithic file), and the box carries the `box_schema: 1.3` stamp. Commit boundaries already use the v1.3.1 pathspec contract. Preserved the draft's strong ideas: replay-not-dump, born-mature as the one accretion exception, role-bucketing inventory, reconcile-stale-state-first, backdated log filenames, reference-vs-archive death-banners, ID discipline, the invariants checklist, the discovery rule.

---

## [v1.3.1] — 2026-06-11

Commit-scoping bugfix. A scribe box whose tracking files live inside the Workbook repo ran `git add -A` during a `do`, sweeping six unrelated `git mv` renames from a concurrent interactive session into its `box: do scribe` commit (`f9de4d1`). Root cause: the commit contract staged the **whole working tree**, relying on the agent to notice and stop on "unrelated changes" — a judgement-based guard that lost to routine boilerplate.

### Changed

- **Pathspec-scoped git, never `add -A`.** Every git operation in the commit contract is now scoped to the box's own root via `-- "$BOX_ROOT"`: `git -C "$REPO" add -- "$BOX_ROOT"`, `git -C "$REPO" commit -m … -- "$BOX_ROOT"`, and the clean-tree check `git -C "$REPO" status --porcelain -- "$BOX_ROOT"`. The pathspec on `commit` is the real safety net — `git commit -- <pathspec>` commits only matching paths regardless of index state, so a concurrent session's staged work is physically untouchable. Updated in SKILL.md (commit-before-edit + clean-tree skip) and protocols `new.md`, `import.md`.
- **`$CONTEXT_REPO` → `$REPO` + `$BOX_ROOT`.** The contract now distinguishes the repo root (`$REPO`, resolved via `readlink -f .context` for context-repo boxes, or the workbook root for boxes living directly in a repo) from the box's own subdirectory (`$BOX_ROOT`). Clean-tree skip and the "unrelated changes → stop and ask" guard now scope to the box root, not the whole tree.

---

## [v1.3] — 2026-06-10

The spec/plan split. A usage sweep over four real boxes (flaky-tests, pr-4751-sso-review, dependabot-remediation, quickbeam-openfn-spike) showed box "plans" were thin — closer to a spec than a hand-to-an-agent plan — and the heaviest box had already grown a per-item plan folder by hand. v1.3 ratifies that: the unit of work is now the **item**, each addressable at `items/<id>/`, with the README a projected index over them.

### Added

- **`spec <id>` verb** — composes `items/<id>/spec.md`: what/why and the load-bearing architectural *how*, with open questions **allowed** and recorded as inline `[NEEDS CLARIFICATION]` markers. Dispatches fresh research agents per area. Box-native — no Claude Code plan mode anywhere in the path. A readiness checklist at its foot gates the `needs-discovery → ready` transition. Protocol: `protocols/spec.md`; template: `templates/spec.md`.
- **`do <id>` verb** — the resourceful executor. Reads `spec.md` **and** `plan.md`, gauges the work using the plan's explicit per-phase dependencies and `[P]` parallel-safe markers, and chooses an approach (single agent / fan-out / dynamic `Workflow` / a per-box `workflow.js` it authors on demand) — no hardcoded implement→review→simplify→check pipeline. Output location is box-type-dependent: a review writes findings and a draft *into* the box; a build writes code to the *real repo* and leaves only thinking in the box (never commits a build into `.context`). Runs only on an explicit go; logs its outcome to `log/`, then offers to mark the item `done` and `rollup`. Protocol: `protocols/do.md`.
- **`migrate` verb** — brings an older box up to `box_schema: 1.3`: splits `follow-ups.md` → `follow-ups/F<n>.md`, hoists the plan into `items/<id>/`, normalises log filenames, and re-stamps the schema. Idempotent (a 1.3 box is a no-op); never renumbers F-/Q-IDs; reports a diff plus a "needs manual attention" list. Protocol: `protocols/migrate.md`.
- **Item folders** — the unit of work is now the item at `items/<id>/`, with up to two artefacts: `spec.md` (at `needs-discovery`) and `plan.md` (at `ready`). The state→artefact mapping: `stub` (no artefact) → `needs-discovery` (`spec.md`) → `ready` (`plan.md`) → `done` (demoted to `archive/`). Not every item needs both: spec is optional when there is nothing to discover; a mechanical item can be plan-only.
- **`box_schema` frontmatter stamp** — `new` stamps `box_schema: 1.3`; every future review round reads it to compare like-for-like, and `migrate` is the lever to converge stragglers.
- **Follow-ups as a folder** — `follow-ups/<F-id>.md`, one file per parked follow-up (was the lone monolithic `follow-ups.md`). F-IDs still never reused or renumbered; the README projected zone aggregates the open ones.
- **Handoff dead-ends field** — `handoff` and `park`'s carry-forward now carry a `do-not` / dead-ends field (approaches already ruled out — negative knowledge) plus a `validation-evidence` line, so a fresh session does not re-walk dead paths.
- **"A box is for many items" principle** — surfaced prominently in `SKILL.md`: the items, plural, are the work; the opening move is orient + decompose; the decomposition/design is the head item that projects the others. The skill does not default to a single all-encompassing item.
- **Templates** — `templates/spec.md` (Problem/Current/Desired triple, EARS acceptance criteria, Assumptions distinct from Open Questions, `[NEEDS CLARIFICATION]` markers, readiness checklist) and `templates/plan.md` (phases phrased WHAT-not-HOW, per-phase Automated/Manual success criteria, requirement back-reference, explicit dependencies + `[P]` markers).

### Changed

- **`plan` is box-native** — the `plan` verb no longer uses Claude Code's native plan mode. With an item id, `plan <id>` composes `items/<id>/plan.md` (the → `ready` transition); bare/steer `plan` manages the track (add/reorder/set-state, `plan next` surfaces the next ready item). Phases are phrased as WHAT (units + acceptance + constraints + context), not a HOW command script — `do` decides how to dispatch them. The plan refuses to finalise while any open question remains. All `ExitPlanMode` / native-plan-mode coupling removed.
- **`argument-hint`** — now lists all 13 verbs: `new · open · status · plan · spec · do · migrate · park · note · handoff · pickup · rollup · close`.
- **README is a projected index over items** — it carries the track (ordered items + states + one-liners) in its projected zone; the substance lives in `items/<id>/`. No inline plan body.
- **Done-item demotion ownership made explicit** — `rollup` folds a `done` item off the active track view but leaves its body at `items/<id>/` (addressable during active work); `close` performs the one terminal relocation of the body to `archive/items/<id>/`. A done item is *completed*, not *superseded*, so it carries no `superseded_by` banner. (Resolves the rollup-vs-close boundary the build review flagged.)

### Removed

- **Claude Code native plan mode coupling** from `plan` — and the `/create-plan` legacy routing note it replaced. Composition is box-native end to end.

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
