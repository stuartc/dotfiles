# Protocol: plan

`plan` is **two operations disambiguated by the id arg** — like `git stash` vs `git stash <cmd>`:

- **Bare / freeform steer** — manage the **track**: add items, reorder, set states, surface what's next. Orientation only.
- **`plan <id>`** — compose or refine `items/<id>/plan.md`: the agent-actionable plan for one item, the `needs-discovery → ready` (or `stub → ready`) transition.

Either way, `plan` **arranges** the work — it does not execute it. Stu composes in one session and executes (`box do <id>`) in another; respect that boundary hard. `plan next` surfaces the next ready item; it never starts doing it.

**A box is for *many* items.** The items, plural, are the work. The opening move is to orient and **decompose** — a box's head item is usually a decomposition/design item whose deliverable is the *other* items. When the track holds a single all-encompassing item, that's a smell: prompt to cut the work up rather than marching one mono-item through `spec → plan → do`. See SKILL.md "a box is for many items".

## Args

`plan [add <text> | next | <id> | <freeform steer>]`

- `plan` (bare) — show the current track and offer edits.
- `plan add <text>` — append a new item to the track. Default state `stub`, unless the text is already crisp and actionable → `ready`.
- `plan next` — surface the next `ready` item for the user to pick up (then `box do`). Orientation only — never starts the work.
- `plan <id>` — compose/refine `items/<id>/plan.md` for that item (see §Composing an item plan).
- `<freeform steer>` — natural-language instruction against the track: reorder, mark an item done, promote one to `ready`, demote another, record the items a decomposition produced. Interpret and apply.

## Steps

### 1. Parse the mode

Read the first token after `plan`.

- **An item id** (e.g. `i3`, or whatever id convention the track uses) → §Composing an item plan. This is the heavyweight path: it authors `items/<id>/plan.md`.
- **`add <text>`** — append a track line per `templates/plan-item.md`: `` - [ ] <id> · <text>  `[stub]` `` (assign the next free item id). If `<text>` reads as crisp and immediately actionable (a verb, a concrete target, no open unknowns), use `` `[ready]` `` instead. Don't over-classify — when unsure, `stub` is the honest default. Light edit, inline.
- **`next`** — find the first item that isn't `done`, in track order.
  - `ready` → surface it: print the intent and point at `items/<id>/plan.md` if it exists, then hand it to the user to start (`box do <id>`). Do **not** begin the work.
  - `needs-discovery` → say so plainly; the next move is `box spec <id>`, not execution.
  - `stub` → prompt to flesh it out first — `box spec <id>` (if there's discovery to do) or `plan add`-style description before it can be made `ready`.
  - There is no `in-progress` state — "currently working" is carried by the live session and any handoff, not a tag.
- **bare `plan`** — print the current track (every item with its state tag) and offer edits. Light edit, or a substantial reshape (see the *Reshaping the track* bullet in §2).
- **freeform steer** — interpret against the item list and apply (reorder, mark X `done`, promote Y, demote Z, **record the items a decomposition item produced** — adding several new stubs/needs-discovery items at once is the normal decomposition output). Confirm only if the target is genuinely ambiguous. Light edit for a single item; for a substantial reshape see the *Reshaping the track* bullet in §2.

### 2. Track edits (inline, box-native — never plan mode)

The track lives in the README's projected/index zone (and migrates to a fuller list as the box grows). **All track operations are box-native and conversational. Never invoke Claude Code's native plan mode, and never call `ExitPlanMode`** — those gate *code* execution; the box `plan` produces a *document* track and executes in a later session via `box do`. The code-gate is the wrong shape and was the v1 friction this verb is built to remove.

- **Light edits** — add/reorder one item, flip one item's state, surface the next item, record a handful of decomposition-produced items. Apply directly, inline. After applying: commit (§Commit-before-edit) and report (§Report).
- **Reshaping the track** — laying out the work track from scratch, or substantially reordering many items: do it **box-natively in conversation** — propose the reshaped track, let Stu react, then write it in. No mode switch, no three-door code-gate. This is composition, not a build trigger.

### 3. States

Four states, set via the trailing tag convention — a Markdown checklist line with the state in a trailing `` `[state]` `` tag (see `templates/plan-item.md`). The checkbox tracks completion; the tag tracks lifecycle:

```
- [ ] <id> · <intent>  `[stub]`
- [ ] <id> · <intent>  `[needs-discovery]`
- [ ] <id> · <intent>  `[ready]`
- [x] <id> · <intent>  `[done]`
```

The lifecycle is `stub` → `needs-discovery` → `ready` → `done`, mapped onto the per-item artefacts:

- `stub` — placeholder; no artefact yet. Known to exist, not yet described.
- `needs-discovery` — known but not understood; `items/<id>/spec.md` is the artefact (`box spec <id>`). Open questions allowed and visible here — this is the human slow-down.
- `ready` — `items/<id>/plan.md` is written, agent-actionable, **zero open questions**. A fresh session could `box do <id>` it.
- `done` — complete. Tick the checkbox (`- [x]`) **and** set the tag to `` `[done]` ``.

These aren't a strict ladder. **Not every item needs both artefacts:** spec is optional when there's nothing to discover — promote `stub → ready` and write the plan directly; a review item may be spec-heavy with a thin plan; a mechanical item may be plan-only. The spec is what you write when *understanding* is the risk; the plan is the thing `box do` runs against. Apply what the user asks — the ordering is the common path, not a gate.

### 4. Composing an item plan (`plan <id>`)

This authors `items/<id>/plan.md` — the agent-actionable artefact, the `→ ready` transition. It is box-native composition: **no plan mode, no `ExitPlanMode`**.

1. **Resolve and read.** Resolve the box root (§Resolve and read). Read `items/<id>/spec.md` if it exists (the plan executes what the spec decided); read any existing `items/<id>/plan.md` to refine rather than clobber.
2. **Refuse to finalise with open questions.** A plan is `ready` only when there are **zero open questions** — no `[NEEDS CLARIFICATION]` markers, no "TBD", no unresolved design forks. If discovery is incomplete, the item belongs in `spec` (`box spec <id>`), not here. Say so and stop rather than writing a plan over unanswered questions.
3. **Compose from `templates/plan.md`.** Copy `${CLAUDE_SKILL_DIR}/templates/plan.md` into `items/<id>/plan.md` and fill it. The plan is **much closer to real code than the spec** — implementation mechanics live here. Sections (per the template): Overview · Current State · Desired End State + how to verify · What We're NOT Doing · Phases · References.
4. **Phrase phases as WHAT, not HOW.** Each phase names a **unit of work + its acceptance + constraints + injected context excerpts** — not a command script, not "run these tool calls in this order". A plan that prescribes the *how* (specific tool calls, file-write order) bleeds into harness territory and ages badly; a plan that specifies *what* + acceptance + constraints stays useful. **`box do` is the harness layer that assigns the agents and decides how to dispatch.** The plan does not script execution; it names the phases as units. The global fresh-agent-per-phase rule still holds — it means the plan *names* phases as the units `do` will hand to fresh agents, not that the plan scripts their commands.
5. **Per phase, carry:**
   - **Automated / Manual success criteria** (the box's existing strength — keep it). Automated = commands an agent can run (tests, lint, typecheck, file existence); Manual = what a human must eyeball.
   - **A requirement back-reference** to the spec criterion the phase satisfies — `_satisfies: <spec-criterion>_` (e.g. an EARS acceptance id from `items/<id>/spec.md`). Omit only when the item is plan-only (no spec).
   - **Explicit dependencies + a `[P]` parallel-safe marker.** Name which earlier phase(s) a phase depends on; tag `[P]` when it can run in parallel with its siblings. This is precisely the signal `box do` reads to choose serial vs parallel dispatch — don't leave dependency implied by order alone.
   - **Injected context excerpts** so a fresh agent on a later phase doesn't re-read an earlier phase's output to learn its starting state.
6. **Optional, risky-phase-only:** a hypothesis/pivot pre-registration block. Use it only for genuinely risky phases — never a required section.
7. **Do not bake execution state into the plan.** `box do` writes its outcome to `log/`, not back into `plan.md`. No "Dev Agent Record" section — `log/` + handoff/pickup already carry execution state across sessions.

### 5. Three doors after composing

After composing or reshaping (a `plan <id>` author, or a substantial track reshape), **do not auto-execute.** Offer three doors explicitly:

1. **Action it now** — for an item plan: "Want me to `box do <id>`?" For the track: "Ready to spec/plan the head item?"
2. **Write it into the box** — commit the artefact (`items/<id>/plan.md`, or the reshaped track) per §Commit-before-edit.
3. **Discuss / iterate further** — "Want to reshape anything before we write it in?"

Wait for Stu to choose. Never proceed to execution (`box do`) without an explicit go. This is the same plan-vs-execute boundary `new` and `spec` respect.

### 6. Resolve and read

Resolve the box root per the contract (`.context/stuart/boxes/<slug>/`, or the box the user pointed at, or the most-recently-modified box). Read the track from the README's projected/index zone, and — for `plan <id>` — `items/<id>/spec.md` and any existing `items/<id>/plan.md`.

### 7. Done items

When an item hits `done`, `plan` only sets the state — it does **not** archive. `done` items stay ticked in place; `box rollup` / `box close` handle demotion to `archive/`. `rollup`'s Next moves excludes done items by construction. `plan` sets the state; `rollup` stops surfacing it. Single source of truth, matching `rollup`.

### 8. Commit-before-edit, then apply

Per the contract: before editing, stage and commit the current state — `box: snapshot before plan`. If the working tree has unrelated changes, stop and ask rather than sweeping them in. `.context/` is usually its own git repo (often a symlink) — resolve the repo root once: `CONTEXT_REPO=$(readlink -f .context)` (use `greadlink -f` if unavailable) and run git with `git -C "$CONTEXT_REPO" …`; do **not** `cd` into the target. Snapshot with `git -C "$CONTEXT_REPO" commit -m "box: snapshot before plan"` (skip silently if the tree is clean).

Apply the edits. Append a Log event from `${CLAUDE_SKILL_DIR}/templates/log-entry.md`: `log/YYYY-MM-DDTHH-MM-plan-updated.md` for a track change (name what changed — items added, reordered, state-changed), or `log/YYYY-MM-DDTHH-MM-plan-written.md` when `items/<id>/plan.md` is authored/refined (name the item). Then `git -C "$CONTEXT_REPO" add -A` and `git -C "$CONTEXT_REPO" commit -m "box: plan <slug>"`.

### 9. Report

One or two lines: what changed, and — for `next` — the next `ready` item and its `box do <id>` next move; for `plan <id>`, whether the item reached `ready` (or what's still blocking it). Don't recap the whole track unless asked.

## Notes

- **Plan arranges; it does not execute.** Every mode stops at the artefact. `plan next` surfaces and hands over — it never starts. `box do <id>` is the execution verb; `plan` only readies items for it.
- **`plan` is overloaded by the id arg.** Bare/steer manages the track; `plan <id>` authors `items/<id>/plan.md`. Disambiguated by the id (cf. `git stash` vs `git stash <cmd>`), and symmetric with `box spec <id>`.
- **Box-native composition only — no native plan mode, ever.** The box `plan` produces a document track and an item plan, executed later by `box do`. Claude Code's native plan mode and `ExitPlanMode` gate *code* execution and are the wrong shape — never invoke them here. (`/create-plan` is the retired skill this verb's template was harvested from; do not route to it.)
- **WHAT not HOW.** An item plan names units of work + acceptance + constraints + context. It does not script tool calls or file-write order — that's `box do`'s harness layer, which assigns the agents.
- **No open questions in a `ready` plan.** If understanding is incomplete, that's `spec` work, not `plan` work. A plan with open questions is a spec wearing the wrong hat.
- **Per-phase deps + `[P]` are load-bearing.** They're the exact signal `box do` reads to choose serial vs parallel dispatch. Don't leave dependency implied by order.
- **A box is for many items.** When the track collapses to one mono-item, prompt to decompose — the head item is usually a decomposition/design item that projects the others.
- Item lines must match `templates/plan-item.md` exactly: a checklist line with a trailing `` `[state]` `` tag. Don't invent alternative state syntax.
