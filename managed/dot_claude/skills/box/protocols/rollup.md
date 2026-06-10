# Protocol: rollup

Regenerate the README's projected zone from the source-of-truth files, and demote done/superseded material out of the active view. The source files (the track + `items/<id>/`, `follow-ups/`, `log/`, `archive/`) are the truth; the projected zone is a *view* composed from them. `rollup` recomposes that view and keeps the active surface small — it never invents state the sources don't carry.

Manual only. There is no auto-trigger — Stu runs this by hand when the README feels out of sync, after a burst of activity, or before bootstrapping a fresh session.

## Args

`rollup` — no args.

## Steps

### 1. Resolve

Resolve the box root per the contract: `.context/stuart/boxes/<slug>/` relative to `pwd`, or the box the user pointed at (`box is here: <path>`), or the most-recently-modified box under `.context/stuart/boxes/`. Ask only if genuinely ambiguous.

### 2. Read the source-of-truth files

These are the truth. The projected zone is derived from them, not the other way round.

- **The track** — for item states. The ordered item list in the README's `## Track` / projected zone; read every item's trailing `` `[state]` `` tag (`stub` / `needs-discovery` / `ready` / `done`). Item bodies live under `items/<id>/` (`spec.md` / `plan.md`) — rollup derives states from the track, it doesn't open the bodies.
- **`follow-ups/`** — read each `follow-ups/F<id>.md` for open entries and their dispositions (`in-scope-later` / `→ issue` / `→ new box` / `dropped`). Reconciled or dropped entries are not "open".
- **The open-question set** — derive it from `log/` **filenames** (the append-only truth, not the README): the open questions are all `…-open-question-Q<n>.md` files **minus** any `Q<n>` that also appears in a `…-question-resolved-Q<n>.md` filename. Scan the full set for this — a resolution can predate the latest events.
- **The last several `log/*.md`** — filenames are timestamped, so sort by name and read the latest N (≈5–8). Care most about `decision` and `note` events to inform the one-line state. (Open questions come from the filename scan above, not from reading these bodies.)
- **The `archive/` listing** — for docs already demoted, so the document map can name them as superseded rather than re-demoting them.

Apply the discovery-before-commitment rule: this is all local file reads, so no fan-out — but don't paginate through the entire log history; the latest several events are enough.

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

<open `F<id>` entries, one line each, with disposition; reconciled/dropped ones drop off here>

- F1 — <one-line summary>  `[in-scope-later]`
- F3 — <one-line summary>  `[→ issue]`

### Open questions

<raised minus resolved: every `open-question-Q<n>` filename whose `Q<n>` has no matching `question-resolved-Q<n>` — these stay visible even while undecided>

- Q<n> — <question>  (raised <date>, still open)
```

Notes on composition:

- **State** is one honest line about the present, not a status badge. Derive it from the latest plan/log activity — what's actively being worked (the nearest `ready` item), what just landed, what's blocked.
- **Document map** is current vs superseded. Live docs sit in the box root; superseded docs live in `archive/` and are named as such, each pointing at what replaced it.
- **Next moves** lists only track items not yet `done`, in track order, the next few. A `needs-discovery` item is called out as such — never dressed up as `ready`. Done items do not appear here (see step 4).
- **Open follow-ups** shows only open `F<id>` entries. An entry that has been reconciled or `dropped` falls off this list; its ID lives on as `follow-ups/F<id>.md` (IDs are never reused; the file is never deleted, only its disposition tag changes).
- **Open questions** is the raised-minus-resolved set from the `log/` filenames (step 2): every `open-question-Q<n>` with no matching `question-resolved-Q<n>`. Each bullet carries its `Q`-ID. **These stay visible even while undecided — never demote an undecided question.** Visibility over tidiness.
- **Empty sections.** An empty section writes `_None yet._` as its sole body line — never omit a `###` sub-section. The structure stays constant whether or not there's content, so the live-adds (`park`/`note`) always have a coherent head to replace into.

### 4. Demote done & superseded (archival without pollution)

The discipline that keeps the active surface small. Drive status honestly by construction — `rollup` owns these transitions so they don't rot the way hand-maintained status does.

- **Done items** stay ticked in place — `rollup`'s Next moves excludes them by construction (the section lists only items not yet `done`). There is no recording step: no Log entry, no `## Done` tail, no move. `plan` sets the `done` state; `rollup` stops surfacing it; neither relocates it.
- **Superseded docs** move to `archive/`. Each demoted doc gets, at the very top of its body, the death-banner:

  ```
  **SUPERSEDED (<date>) — see <X>. Do not act on this.**
  ```

  and a `superseded_by: <X>` field in its YAML frontmatter. Log one `superseded:<doc>` event per demotion (timestamp, what was demoted, what replaced it, one line of why).
- **Keep open questions visible.** Archival demotes the *done* and the *superseded*, never the *undecided*. An open question stays in the projection until it is genuinely resolved.

The goal: the active box root shows only live material. Don't rely on a hand-maintained current-vs-archaeology table — the demotion plus the death-banner is the defence.

### 5. Write the README

Read the current `README.md`. Preserve everything **outside** the markers — the static zone above is hand-curated and `rollup` never touches it. Replace **only** the content between:

```
<!-- BOX: BEGIN PROJECTED -->
```

and

```
<!-- BOX: END PROJECTED -->
```

with the freshly composed `## Where things stand` block from step 3.

If the markers are missing — someone hand-edited them out — **warn the user and ask** before reconstructing them. Don't silently re-insert markers and overwrite hand-edited content.

### 6. Commit-before-edit, then write

Per the contract: before editing, stage and commit the current state — `box: snapshot before rollup`. If the working tree has unrelated changes, stop and ask rather than sweeping them in. `.context/` is usually its own git repo (often a symlink) — resolve the repo root via `readlink -f .context` and run git with `git -C <repo> …`; do **not** `cd` into the target.

Write the README projected zone and any `archive/` demotions. Append a `rolled-up` Log event (short: timestamp, that the projection was regenerated, the counts). Then `git -C <repo> add -A` and `git -C <repo> commit -m "box: rollup <slug>"`. No co-author lines, no skip-hooks.

### 7. Report

One line: the projected zone was regenerated, with counts — N items, M open follow-ups, K open questions (raised minus resolved), any `Q<id>`s resolved since the last rollup, and any docs demoted this run.

## Notes

- **Rollup is derived data.** The projected zone is replaceable; the source files (the track + `items/<id>/`, `follow-ups/F<id>.md`, `log/*.md`, `archive/`) are the truth. To recover from a botched rollup, delete the projected zone between the markers and re-run — nothing is lost.
- **The static zone is hand-curated and never touched.** The prize, repo facts, and origin live above the `<!-- BOX: BEGIN PROJECTED -->` marker. If they need updating, edit them by hand — `rollup` only ever rewrites between the markers.
- **Archival demotes the done, never the undecided.** Done items and superseded docs leave the active view; open questions stay visible until resolved. Visibility over tidiness.
- **`close` also demotes.** `rollup` and `close` share the archival machinery; `close` additionally reconciles every open follow-up to a terminal disposition and records terminal state. `rollup` excludes done items from Next moves by construction **and** demotes superseded docs to `archive/` — it's the demoter for documents. `plan` sets `done` states but never archives.
