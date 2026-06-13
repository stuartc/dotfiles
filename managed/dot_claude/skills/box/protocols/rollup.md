# Protocol: rollup

Regenerate the README's projected zone from the source-of-truth files, and move done/superseded material out of the active view. The source files (the track + `items/<id>/`, `follow-ups/`, `log/`, `archive/`) are the truth; the projected zone is a view composed from them. `rollup` recomposes that view and keeps the active surface small — it never invents state the sources don't carry.

Manual only. There is no auto-trigger — Stu runs this when the README feels out of sync, after a burst of activity, or before bootstrapping a fresh session.

## Event types

The full set of log event types (each writing protocol names the ones it emits; `rollup` is the verb that scans across all of them). Filename rule per SKILL.md: a `:` becomes `-`.

- `born` — box created
- `seeded-from-pr` / `seeded-from-issue` — box seeded from a public ref
- `plan-updated` — track items added / reordered / state-changed
- `spec-written` — an item's `spec.md` authored or refined
- `plan-written` — an item's `plan.md` authored or refined (the `→ ready` transition)
- `do-ran` — an item executed; points at where the output landed
- `followup-parked:F<id>` — one event per park (or one covering several parked together)
- `note` — a logged discovery / observation
- `decision` — a decision recorded
- `open-question:Q<id>` — an unresolved question raised; stays visible in the README until settled
- `question-resolved:Q<id>` — a previously raised question settled; drops off the README, stays in the log forever
- `rolled-up` — README projected zone regenerated
- `handoff` — a carry-forward prompt written (points at the `handoffs/` file)
- `superseded:<doc-or-id>` — a document moved to `archive/`, or an item (or several) marked `superseded` on the track; the body moves at `close`
- `closed` — box closed, terminal state recorded

## Args

`rollup` — no args.

## Steps

### 1. Resolve

Resolve the box root per SKILL.md. Ask only if genuinely ambiguous.

### 2. Read the source-of-truth files

- **The track** — the ordered item list in the README; read every item's trailing `` `[state]` `` tag. Item bodies live under `items/<id>/` — rollup derives states from the track, it doesn't open the bodies.
- **`follow-ups/`** — each `follow-ups/F<id>.md`, for open entries and their dispositions. Reconciled or dropped entries are not "open".
- **The open-question set** — derive it from the `log/` **filenames** (the append-only truth, not the README): all `…-open-question-Q<n>.md` files **minus** any `Q<n>` that also appears in a `…-question-resolved-Q<n>.md` filename. Scan the full set — a resolution can predate the latest events.
- **The last several `log/*.md`** — filenames are timestamped, so sort by name and read the latest ~5–8 bodies. The `decision` and `note` events inform the one-line state.
- **The `archive/` listing** — for docs already archived, so the document map can name them as superseded rather than re-moving them.

All local file reads — no fan-out, and don't read the entire log history; the filename scan plus the latest several bodies is enough.

### 3. Compose the projected zone

Compose the `## Where things stand` block exactly as the template ships it (`${CLAUDE_SKILL_DIR}/templates/README.md`), regenerating these `###` sub-sections in this order:

```markdown
## Where things stand

_Last rolled up: <ISO datetime>_

### State

<one line: what's happening right now, derived from the latest plan/log activity>

### Document map

<live docs in the box root; superseded ones noted as living in `archive/`>

- `README.md` — the head (this file)
- `items/<id>/spec.md` / `items/<id>/plan.md` — item bodies
- `archive/<doc>.md` — superseded, see `<X>`

### Next moves

<the next few track items not yet `done`, in track order — call out `needs-discovery` markers explicitly>

- <intent>  `[ready]`
- <intent>  `[needs-discovery]` — discovery happens conversationally when you reach it

### Open follow-ups

- F1 — <one-line summary>  `[in-scope-later]`
- F3 — <one-line summary>  `[→ issue]`

### Open questions

- Q<n> — <question>  (raised <date>, still open)
```

Composition rules:

- **State** is one accurate line about the present, not a status badge: what's actively being worked, what just landed, what's blocked.
- **Document map** is current vs superseded. Live docs sit in the box root; superseded docs live in `archive/`, each pointing at what replaced it.
- **Next moves** lists only items not yet `done`/`superseded`, in track order. A `needs-discovery` item is named as such — never presented as `ready`.
- **Open follow-ups** shows only open `F<id>` entries. A reconciled or `dropped` entry falls off this list; its file stays under `follow-ups/` (per the ID rules in SKILL.md, IDs are never reused and files never deleted — only the disposition tag changes).
- **Open questions** is the raised-minus-resolved set from step 2, each bullet carrying its `Q`-ID. **An undecided question is never removed from this list** — only a `question-resolved` event drops it.
- **Empty sections** write `_None yet._` as their sole body line — never omit a `###` sub-section. The structure stays constant so the live-adds from `park`/`note` always have a section to replace into.

### 4. Move done and superseded material out of the active view

- **Done items** stay ticked in place — Next moves excludes them by construction. No log entry, no move: `plan` sets the `done` state; `rollup` stops listing it and leaves the body at `items/<id>/` (still addressable during active work). `close` performs the one terminal move to `archive/items/<id>/` at end-of-box.
- **Superseded docs** move to `archive/`. Each gets, at the very top of its body, the SUPERSEDED banner:

  ```
  **SUPERSEDED (<date>) — see <X>. Do not act on this.**
  ```

  and a `superseded_by: <X>` field in its YAML frontmatter. Log one `superseded:<doc>` event per move (timestamp, what was moved, what replaced it, one line of why).
- **Open questions stay visible.** Archiving is for the done and the superseded, never the undecided.

The goal: the active box root shows only live material, kept that way by construction rather than by a hand-maintained status table.

### 5. Write the README

Read the current `README.md`. Preserve everything outside the projected-zone markers — the static zone is hand-written and `rollup` never touches it. Replace only the content between the markers with the freshly composed block from step 3.

If the markers are missing — someone hand-edited them out — warn the user and ask before reconstructing them. Don't silently re-insert markers over hand-edited content.

### 6. Commit

Per the commit contract in SKILL.md (`box: snapshot before rollup` … `box: rollup <slug>`). Append a `rolled-up` log event (short: timestamp, that the projection was regenerated, the counts).

### 7. Report

One line: the projected zone was regenerated, with counts — N items, M open follow-ups, K open questions (raised minus resolved), any `Q<id>`s resolved since the last rollup, and any docs archived this run.

## Notes

- **The projected zone is derived data.** To recover from a botched rollup, delete the content between the markers and re-run — nothing is lost.
- **`rollup` and `close` split the archiving.** `rollup` stops listing done items and moves superseded *documents* to `archive/`; `close` additionally reconciles every open follow-up and moves done item *bodies* (`items/<id>/` → `archive/items/<id>/`). `plan` sets `done` states but never archives.
