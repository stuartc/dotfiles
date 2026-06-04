# Protocol: note

Log a decision, discovery, or open question into the Log. `note` is the **lighter sibling of `park`**: no disposition, no follow-up entry, no handoff, no `F<id>`. Just a durable Log event — provenance worth remembering that isn't an actionable follow-up.

Use it for the thing you'll want to know *why* about in five days: a choice made, a fact discovered, a question you can't yet answer. If the thing is actionable and needs routing, it's a `park`, not a `note` (see Notes).

## Args

`note <text>`

- With text: classify and write the note.
- Without text: ask what to record. Don't auto-scan the session — a note is a deliberate act of human judgement about what's worth keeping, not a digest of everything that happened.

## Steps

### 1. Resolve

Resolve the box root (per the contract's box-root resolution rule): `.context/stuart/boxes/<slug>/` relative to `pwd`, or the box the user pointed at (`box is here: <path>`), or the most-recently-modified box under `.context/stuart/boxes/`. If it's genuinely ambiguous, ask.

### 2. Classify

Infer the Log event type from the text. Confirm only if it's genuinely ambiguous — don't interrogate.

- `decision` — a choice made. "We'll treat the PR as source of truth." "Dropping SQLite support."
- `open-question` — an unresolved question. "Still don't know how to handle multi-region failover." "Unclear whether the loader retries are idempotent."
- `note` — a discovery or observation that's neither a firm decision nor an open question. "Turns out the worker already retries on 429."

When the text reads like both a decision and the reasoning behind it, prefer `decision`. When it ends in a question or names something unknown, prefer `open-question`.

### 3. Write the Log event

`log/` exists from the box's birth (the `new` protocol writes the first event). Create `log/YYYY-MM-DDTHH-MM-<type>.md` from `templates/log-entry.md`, where `<type>` is `decision`, `open-question`, or `note`. Fill it:

- **When:** the ISO datetime.
- **What changed:** the decision / question / observation in one line, plus one line of context — enough that it stands alone in five days without re-reading the session.
- **Artefact:** a pointer if there is one (a file, a PR ref, a `plan.md` item); otherwise "—".
- **Context:** the one line of why it matters or how it surfaced.

Keep it 5–20 lines. The Log is append-only — never edit an event after writing it.

### 4. Open questions stay visible

If the type is `open-question`, the question must surface in the README's projected `### Open questions` section. It must never be hidden — visibility over tidiness; archival demotes the *done*, never the *undecided*.

`rollup` regenerates `### Open questions` from `open-question` Log events, so the question will appear there on the next `rollup` regardless. But don't make visibility wait on a rollup: live-add the bullet to `### Open questions` now (between the projected-zone markers), mirroring how `park` live-adds to `### Open follow-ups`. A live edit and a later rollup stay consistent because both read from the same `open-question` events.

If the projected-zone markers are missing, warn and ask before touching the README — don't reconstruct it.

For `decision` and `note` types, the README is not touched here; `rollup` folds them into the projected zone when it next runs.

### 5. Commit

Commit-before-edit applies. Snapshot the current state first (`box: snapshot before note`), then write. After writing, commit `box: note <slug>`. `cd` into the `.context/` symlink target to run git there. No co-author lines, no skip-hooks. If the working tree has unrelated changes, stop and ask rather than sweeping them in.

### 6. Report

One line: the type recorded (`decision` / `open-question` / `note`) and the event filename. For an `open-question`, add that it's now visible in the README's `### Open questions` and will persist there until resolved.

## Notes

The park-vs-note line, drawn clearly:

- **`park`** — an actionable follow-up. It carries a **disposition** naming where it goes (`in-scope-later` / `→ issue` / `→ new box` / `dropped`), gets a permanent `F<id>`, lands in `follow-ups.md`, and may spin off a carry-forward handoff. At `close` it must reconcile to a terminal disposition. Park is for *work that still needs doing or routing*.
- **`note`** — provenance into the Log. No disposition, no `F<id>`, no handoff, nothing to reconcile at `close`. Note is for *something worth remembering*, not something to do.

The test: if it needs to be done or routed somewhere, it's a `park`. If it just needs to be remembered, it's a `note`. A decision you've already made is a `note` (`decision`); a decision you still have to make is usually an `open-question` note, and only becomes a `park` once acting on it is itself a unit of work.

An `open-question` note is the one type with README presence — because an undecided thing left invisible is the failure mode the box exists to prevent. Everything else in the Log waits for `rollup` to project it.
