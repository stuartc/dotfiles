# Protocol: plan

Work the plan: add items, reorder, set states, surface what's next. `plan` **arranges** the work — it does not execute it. Stu plans in one session and executes in another; respect that boundary hard. `plan next` surfaces the next item; it never starts doing it.

## Args

`plan [add <text> | next | <freeform steer>]`

- `plan` (bare) — show the current plan and offer edits.
- `plan add <text>` — append a new item. Default state `stub`, unless the text is already crisp and actionable → `ready`.
- `plan next` — pull the next `ready` item and surface it for the user to pick up. If the head item is `needs-discovery` or `stub`, don't fake readiness — see step 1.
- `<freeform steer>` — natural-language instruction: reorder, mark an item done, promote one to `ready`, demote another. Interpret and apply.

## Steps

### 1. Parse the mode

Read the first token after `plan`.

- **`add <text>`** — append `` - [ ] <text>  `[stub]` `` to the plan. If `<text>` reads as crisp and immediately actionable (a verb, a concrete target, no open unknowns), use `` `[ready]` `` instead. Don't over-classify — when unsure, `stub` is the honest default.
- **`next`** — find the first item that isn't `done`, in plan order.
  - If it's `ready` → surface it: print the intent and any body, and hand it to the user to start. Do **not** begin the work — `plan next` stops at surfacing.
  - If it's `needs-discovery` → say so plainly. Don't pretend it's ready. Prompt that discovery is **conversational in v1** — there is no discovery verb. Stu dispatches tracing agents in-session ("send off two agents to trace the frontend call…") and the item is promoted to `ready` once understood.
  - If it's `stub` → prompt to flesh it out first. A stub is a placeholder (`<TODO: spec out>`); it needs a description before it can be made ready.
  - If it's `in-progress` → it's already being worked; surface it as the live item rather than pulling a new one.
- **bare `plan`** — print the current plan (every item with its state tag) and offer edits.
- **freeform steer** — interpret against the item list (reorder, mark item X `done`, promote Y to `ready`, demote Z) and apply. Confirm only if the target is genuinely ambiguous.

### 2. Resolve and read

Resolve the box root per the contract (`.context/stuart/boxes/<slug>/`, or the box the user pointed at, or the most-recently-modified box). Read the current plan:

- Inline `## Plan` section in `README.md` — the default home; the plan is born here.
- `plan.md` — if the plan has already split out. Once split, it stays split (one-way); read it there.

### 3. States

Five states, set via the trailing tag convention — a Markdown checklist line with the state in a trailing `` `[state]` `` tag. The checkbox tracks completion; the tag tracks lifecycle:

```
- [ ] <intent>  `[stub]`
- [ ] <intent>  `[needs-discovery]`
- [ ] <intent>  `[ready]`
- [ ] <intent>  `[in-progress]`
- [x] <intent>  `[done]`
```

Setting a state rewrites the item's tag in place. The lifecycle is `stub` → `needs-discovery` → `ready` → `in-progress` → `done`:

- `stub` — placeholder; body is `<TODO: spec out>`. Known to exist, not yet described.
- `needs-discovery` — known but not understood. Discovery happens conversationally when you reach it (no verb in v1).
- `ready` — crisp and actionable; a fresh session could pick it up and run.
- `in-progress` — being worked right now.
- `done` — complete. Tick the checkbox (`- [x]`) **and** set the tag to `` `[done]` ``.

These aren't a strict ladder — a steer may promote a `stub` straight to `ready`, or mark a `ready` item `done` if it turned out trivial. Apply what the user asks; the ordering is the common path, not a gate.

### 4. The split rule

The plan is born inline in the README and stays there until it outgrows the head. Migrate to `plan.md` when the inline `## Plan` section exceeds ~12–15 items, or visibly crowds the README head. On split:

1. Move the whole `## Plan` section out of `README.md` into a new `plan.md`.
2. Leave a one-line pointer in the README plus the next few items inline, so `status` and `rollup` still surface what's next without opening `plan.md`.
3. Update the README "Working layout" tree so `plan.md` is no longer marked "(appears when the plan splits out)" — it now exists.

This is **one-way and on-demand**: once the plan lives in `plan.md` it stays there, and a stub box keeps its plan inline. Never split prematurely.

### 5. Done items

When an item hits `done`, `plan` only sets the state — it does **not** archive. `rollup` is what demotes done items out of the active Next-moves view into the Log. Leave the ticked item in place; don't move or delete it. This avoids double-owning archival between `plan` and `rollup`.

### 6. Commit-before-edit, then apply

Per the contract: before editing, stage and commit the current state — `box: snapshot before plan`. If the working tree has unrelated changes, stop and ask rather than sweeping them in. `.context/` is usually its own git repo (often a symlink) — `cd` into the target to run git there.

Apply the edits. Append a `plan-updated` Log event — short, naming what changed (items added, reordered, or state-changed). Then commit `box: plan <slug>`.

### 7. Report

One or two lines: what changed, and — if the user asked `next` or for it — the next `ready` item. Don't recap the whole plan unless asked.

## Notes

- **Plan arranges; it does not execute.** Every mode stops at the artefact. `plan next` surfaces the next item and hands it over — it never starts the work. This is the same boundary `new` respects.
- **Discovery is conversational in v1.** There is no discovery verb. A `needs-discovery` item is promoted to `ready` in-session, once tracing agents have made it understood.
- **The split is on-demand, never premature.** Inline until ~12–15 items or a crowded head; one-way once split.
- Item lines must match the template marker exactly: a checklist line with a trailing `` `[state]` `` tag. Don't invent alternative state syntax.
