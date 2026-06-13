# Protocol: plan

`plan` is **two operations disambiguated by the id arg** — like `git stash` vs `git stash <cmd>`:

- **Bare / freeform steer** — manage the **track**: add items, reorder, set states, surface what's next.
- **`plan <id>`** — compose or refine `items/<id>/plan.md`: the agent-actionable plan for one item, the `needs-discovery → ready` (or `stub → ready`) transition.

Either way, `plan` arranges the work — it does not execute it (per the plan-vs-execute boundary in SKILL.md). `plan next` surfaces the next ready item; it never starts doing it.

**A box is for many items.** When the track holds a single all-encompassing item, that's a warning sign: prompt to cut the work up rather than running one mono-item through `spec → plan → do`. See SKILL.md.

## Args

`plan [add <text> | next | <id> | <freeform steer>]`

- `plan` (bare) — show the current track and offer edits.
- `plan add <text>` — append a new item to the track. Default state `stub`, unless the text is already crisp and actionable → `ready`.
- `plan next` — surface the next `ready` item for the user to pick up (then `box do`). Never starts the work.
- `plan <id>` — compose/refine `items/<id>/plan.md` (see §Composing an item plan).
- `<freeform steer>` — natural-language instruction against the track: reorder, mark an item done, set one to `ready`, record the items a decomposition produced. Interpret and apply.

## Steps

### 1. Parse the mode

Resolve the box root per SKILL.md and read the track from the README's projected zone. Then read the first token after `plan`.

- **An item id** (e.g. `D1`, `1`, `2` — the folder name under `items/`) → §Composing an item plan.
- **`add <text>`** — append a track line per `templates/plan-item.md`: `` - [ ] <id> · <text>  `[stub]` `` (assign the next free item id). If `<text>` reads as crisp and immediately actionable (a verb, a concrete target, no open unknowns), use `` `[ready]` `` instead. Don't over-classify — when unsure, `stub` is the safe default. Light edit, inline.
- **`next`** — find the first item that isn't `done` or `superseded`, in track order.
  - `ready` → surface it: print the intent, point at `items/<id>/plan.md` if it exists, and hand it to the user (`box do <id>`). Do **not** begin the work.
  - `needs-discovery` → say so plainly; the next move is `box spec <id>`, not execution.
  - `stub` → prompt to flesh it out first — `box spec <id>` if there's discovery to do, or a `plan add`-style description.
  - There is no `in-progress` state — "currently working" is carried by the live session and any handoff.
- **bare `plan`** — print the current track (every item with its state tag) and offer edits.
- **freeform steer** — interpret against the item list and apply (reorder, mark X `done`, set Y to `ready`, record the items a decomposition produced — adding several new stubs at once is the normal decomposition output). Confirm only if the target is genuinely ambiguous.

### 2. Track edits

The track lives in the README's projected zone. All track operations are conversational and box-native — never Claude Code plan mode (per SKILL.md).

- **Light edits** — add/reorder one item, flip one state, record a handful of decomposition items. Apply directly, then commit (§Commit) and report (§Report).
- **Reshaping the track** — laying out the track from scratch or substantially reordering many items: propose the reshaped track in conversation, let Stu react, then write it in.

### 3. States

The five states and their artefacts are defined in SKILL.md's Conventions; the line format is in `templates/plan-item.md` — a checklist line with a trailing `` `[state]` `` tag. The checkbox tracks completion; the tag tracks lifecycle:

```
- [ ] <id> · <intent>  `[stub]`
- [ ] <id> · <intent>  `[needs-discovery]`
- [ ] <id> · <intent>  `[ready]`
- [x] <id> · <intent>  `[done]`
- [x] <id> · <intent>  `[superseded]`  _(by <id(s)> — reason)_
```

For `done`, tick the checkbox **and** set the tag. For `superseded` (closed without being built — scope absorbed or replaced by other items), tick the checkbox, set the tag, and add the `_(by <id(s)> — reason)_` note; record it in the `plan-updated` log event (or a `superseded:<id>` event if several items are affected at once).

The states aren't a strict ladder — per SKILL.md, a spec is optional when there's nothing to discover; set `stub → ready` and write the plan directly.

### 4. Composing an item plan (`plan <id>`)

This writes `items/<id>/plan.md` — the agent-actionable artefact, the `→ ready` transition. Box-native composition: no plan mode, no `ExitPlanMode`.

1. **Resolve and read.** Resolve the box root per SKILL.md. Read `items/<id>/spec.md` if it exists (the plan executes what the spec decided) and any existing `items/<id>/plan.md` — refine, don't clobber.
2. **Refuse to finalise with open questions.** A plan is `ready` only with **zero open questions** — no `[NEEDS CLARIFICATION]` markers, no "TBD", no unresolved design forks. If discovery is incomplete, the item belongs in `spec` (`box spec <id>`), not here. Say so and stop.
3. **Compose from `templates/plan.md`.** Copy `${CLAUDE_SKILL_DIR}/templates/plan.md` into `items/<id>/plan.md` and fill it. The plan is much closer to real code than the spec — implementation mechanics live here. Sections per the template: Overview · Current State · Desired End State + how to verify · What We're NOT Doing · Phases · References.
4. **Phrase phases as WHAT, not HOW.** Each phase names a unit of work + its acceptance + constraints + injected context excerpts — not a command script. `box do` is the layer that assigns agents and decides how to dispatch; the plan names the phases as units it will hand to fresh agents.
5. **Per phase, carry:**
   - **Automated / Manual success criteria.** Automated = commands an agent can run (tests, lint, typecheck); Manual = what a human must eyeball.
   - **A back-reference to the spec criterion the phase satisfies** — `_satisfies: <spec-criterion>_`. Omit only when the item is plan-only.
   - **Explicit dependencies + a `[P]` parallel-safe marker.** Name which earlier phase(s) a phase depends on; tag `[P]` when it can run in parallel with its siblings. This is the exact signal `box do` reads to choose serial vs parallel dispatch — don't leave dependency implied by order alone.
   - **Injected context excerpts** so a fresh agent on a later phase doesn't have to re-read an earlier phase's output to learn its starting state.
6. **Optional, risky-phase-only:** a hypothesis/pivot pre-registration block. Never a required section.
7. **Do not bake execution state into the plan.** `box do` writes its outcome to `log/`, not back into `plan.md`.

### 5. After composing

After composing an item plan or a substantial track reshape, offer the three doors per SKILL.md (action now / write into the box / discuss) and wait for Stu's choice. Never proceed to `box do` without an explicit go.

### 6. Done items

When an item hits `done`, `plan` only sets the state — it does **not** archive. Done items stay ticked in place; `box rollup` stops listing them in Next moves, and `box close` moves their bodies to `archive/`.

### 7. Commit, log, report

Commit per the commit contract in SKILL.md (`box: snapshot before plan` … `box: plan <slug>`). Log event from `${CLAUDE_SKILL_DIR}/templates/log-entry.md`: `plan-updated` for a track change (name what changed), or `plan-written` when `items/<id>/plan.md` is authored/refined (name the item).

Report in one or two lines: what changed; for `next`, the next `ready` item and its `box do <id>` move; for `plan <id>`, whether the item reached `ready` or what still blocks it. Don't recap the whole track unless asked.

## Notes

- The valid state tags are exactly `stub` / `needs-discovery` / `ready` / `done` / `superseded` — don't invent others.
- `/create-plan` is a retired skill this verb's template was harvested from; do not route to it.
