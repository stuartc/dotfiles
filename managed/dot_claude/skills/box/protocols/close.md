# Protocol: close

End the box. Reconcile every open follow-up to a terminal disposition, move done work to `archive/`, record a terminal state in the README static zone, and draft (never post) the PR description. This is the normal ending for a box, not an edge case — the core value is that every parked follow-up gets a final decision, so nothing is silently forgotten.

`close` ends the box; it does not start new work. Where reconciliation points a follow-up at a new box or a GitHub issue, `close` records the routing and drafts the artefact — it does not execute the spun-out work.

## Args

`close [terminal-state]`

- `[terminal-state]` — optional, one of: `done` / `spun-out` / `abandoned` / `superseded-by <slug>`. If omitted, infer from the box state (all items done → `done`; everything routed to issues/new boxes with nothing shipped → `spun-out`; abandoned mid-flight → `abandoned`) and confirm in one line before recording.

## Steps

### 1. Resolve

Resolve the box root per SKILL.md. If it's genuinely ambiguous, ask — closing the wrong box is expensive.

### 2. Refresh the view first

Run `box rollup` before closing, so the projected zone reflects reality before you reconcile against it. Call it by name — don't re-implement its internals here. If the projected-zone markers are missing, warn and ask before proceeding.

Closing against a stale head is how a follow-up gets missed. The refresh is not optional.

### 2a. Snapshot

Steps 3–5 all edit the box, so snapshot first per the commit contract in SKILL.md (`box: snapshot before close`).

### 3. Reconcile every open follow-up

The real work of `close`. Read each `follow-ups/F<id>.md`. For **each** open `F<id>` (anything not already at a terminal disposition), record a final decision — nothing stays merely `in-scope-later` or parked. Update each entry's disposition tag in place so the file records the outcome; the log records the reconciliation summary.

Route each open follow-up to one of:

- **`→ issue`** — record the GitHub issue URL on the entry. If the issue isn't drafted yet, draft it now per the public-leak rule in SKILL.md — plain English, no internal vocabulary, **draft only, never post**. Show Stu the draft; he sends it. If the issue doesn't exist yet, record "issue draft ready — pending Stu" so the routing is unambiguous.
- **`→ new box`** — record the new box slug on the entry. Offer to `box new <slug>` it, but do not start the spun-out work.
- **`in-scope-later` that got done** — mark it done with a pointer to where it landed (the merged change, the track item, the commit).
- **`dropped`** — an explicit kill, with a one-line reason on the entry. A dropped follow-up keeps its `F<id>` forever; it is killed, not deleted.

If a follow-up genuinely can't be reconciled (Stu's away, the routing target is unknown), don't invent a disposition — surface it and ask. A follow-up left with no decision at all is the outcome `close` exists to prevent; "this one needs your call" beats a fabricated kill.

### 4. Move done work and superseded docs to `archive/`

Two distinct moves into `archive/` (created on demand):

**Superseded documents.** For each:

- Add the SUPERSEDED banner at the top of the body, same format as `rollup`: `**SUPERSEDED (<date>) — see <X>. Do not act on this.**` where `<X>` names where the live truth now lives (the merged PR, the successor box, the closing summary).
- Add `superseded_by: <X>` and a closing date to the frontmatter.
- Move the file into `archive/`.
- Append one `superseded:<doc>` log event per move.

**Done and superseded item bodies.** The rollup in step 2 has already stopped listing done items; `close` is the terminal sweep that relocates them. For each `done` item, move its whole `items/<id>/` folder to `archive/items/<id>/`. A done item is completed, not superseded — it gets **no** `superseded_by` banner; its `spec.md`/`plan.md` stay intact as the preserved record. A `superseded` item's body moves the same way, but its `spec.md`/`plan.md` each get the SUPERSEDED banner and `superseded_by:` frontmatter (pointing at the absorbing item or replacement), same as a superseded document. The track line stays in place (it's the index entry). No per-item log event is needed — the `closed` event (step 7) covers the sweep. Items still `stub`/`needs-discovery`/`ready` at close are unfinished work: leave their bodies in `items/` and let the terminal state and follow-up reconciliation account for them — don't archive an unfinished item as if it were done.

**Open questions stay visible.** If the box closes with unresolved questions, they stay surfaced in the README — closing with open questions is a deliberate, recorded choice, not a silent drop (see step 5).

### 5. Record terminal state

Write a `## Closing summary` section in the README **static zone** (above the projected-zone markers — the projected zone belongs to `rollup`). It carries:

- **Terminal state:** `done` / `spun-out` / `abandoned` / `superseded-by <slug>`.
- **Outcome:** one paragraph — what the box achieved (or didn't) and why it's ending.
- **Links:** the merged PR, spun-out issue URLs, the successor box slug — whatever the terminal state points at.

Before writing, **warn and require an explicit acknowledgement** if either holds:

- A track item is still `ready`/`needs-discovery` with real work left.
- An open question is still unresolved — name the specific `Q<id>`s (e.g. "closing with Q2, Q4 unresolved").

Don't block — Stu may legitimately close a box with loose ends — but make him say so. Record the acknowledgement in the closing summary ("closed with X unresolved, deliberately") and in the `closed` log event.

### 6. Draft the PR description

Compose a PR-description **draft** from the box and print it to the conversation for Stu to copy and send. Never post — draft only, per Stu's standing rule.

Source it from the box but translate fully per the public-leak rule in SKILL.md: intent from `## The prize`, the shipped items, decisions from the log, and any caveats worth flagging to a reviewer — written the way a person would describe the change to someone who's never heard of the box.

If the terminal state is `abandoned` or `spun-out` with nothing merged, there may be no PR to describe — say so and skip rather than drafting a hollow description.

### 7. Closing log event + commit

Write `log/YYYY-MM-DDTHH-MM-closed.md` from `${CLAUDE_SKILL_DIR}/templates/log-entry.md` (event type `closed`). It records:

- The terminal state.
- A per-`F<id>` reconciliation summary — each open follow-up and where it went.
- Any still-open questions, by `Q<id>` — the deliberate "closed with Q2, Q4 unresolved" from step 5.
- The outcome in one line, and any deliberate loose ends acknowledged.

Then commit `box: close <slug>`.

### 8. Report

Short summary back to the user:

- Terminal state recorded.
- How many follow-ups reconciled, and to where (e.g. "3 reconciled: 1 → issue, 1 → new box `worker-backpressure`, 1 dropped").
- How many docs archived.
- The reminder: **the PR description draft is printed above, ready for you to send** — it has not been posted.

If anything was left deliberately open (a loose track item, an unresolved question), name it in one line.

## Notes

- **Done-item relocation is `close`'s job, not `rollup`'s.** `rollup` stops listing done items during normal work (bodies stay at `items/<id>/`); `close` performs the one terminal move to `archive/items/<id>/`.
