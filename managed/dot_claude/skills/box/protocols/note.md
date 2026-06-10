# Protocol: note

Log a decision, discovery, or open question into the Log. `note` is the **lighter sibling of `park`**: no disposition, no follow-up entry, no handoff, no `F<id>`. Just a durable Log event — provenance worth remembering that isn't an actionable follow-up.

Use it for the thing you'll want to know *why* about in five days: a choice made, a fact discovered, a question you can't yet answer. If the thing is actionable and needs routing, it's a `park`, not a `note` (see Notes).

## Args

`note <text>`

- With text: classify and write the note.
- Without text: ask what to record. Don't auto-scan the session — a note is a deliberate act of human judgement about what's worth keeping, not a digest of everything that happened.

## Steps

### 1. Resolve

Resolve the box root per the contract's box-root resolution rule. If it's genuinely ambiguous, ask.

### 2. Classify

Infer the Log event type from the text. Confirm only if it's genuinely ambiguous — don't interrogate.

- `decision` — a choice made. "We'll treat the PR as source of truth." "Dropping SQLite support."
- `open-question` — an unresolved question. "Still don't know how to handle multi-region failover." "Unclear whether the loader retries are idempotent."
- `note` — a discovery or observation that's neither a firm decision nor an open question. "Turns out the worker already retries on 429."

When the text reads like both a decision and the reasoning behind it, prefer `decision`. When it ends in a question or names something unknown, prefer `open-question`.

If the text instead **settles** a question already raised — Stu names a `Q<id>` or clearly answers a standing open question ("Q2's settled, going with X") — this is a resolution, not a new event type. Skip to step 6, the Resolution path.

### 3. Assign a Q-ID (open-question only)

Only for the `open-question` type. The authoritative source is the `log/` **filenames**, not the README. Scan them for the highest existing `Q`-number across **both** `…-open-question-Q<n>.md` and `…-question-resolved-Q<n>.md`; the new ID is `max + 1`, or `Q1` if none exist yet. IDs are **never reused or renumbered**. (The README `### Open questions` section is a secondary cross-check only — the filenames are the truth.)

For `decision` and `note` types, skip this step.

### 4. Write the Log event

`log/` exists from the box's birth (the `new` protocol writes the first event). Create `log/YYYY-MM-DDTHH-MM-<type>.md` from `${CLAUDE_SKILL_DIR}/templates/log-entry.md`, where `<type>` is `decision`, `note`, or — for a question — `open-question-Q<n>` (carrying the ID assigned in step 3, e.g. `…-open-question-Q3.md`). Fill it:

- **When:** the ISO datetime.
- **What changed:** the decision / question / observation in one line, plus one line of context — enough that it stands alone in five days without re-reading the session.
- **Artefact:** a pointer if there is one (a file, a PR ref, a `plan.md` item); otherwise "—".
- **Context:** the one line of why it matters or how it surfaced.

Keep it 5–20 lines. The Log is append-only — never edit an event after writing it.

### 5. Open questions stay visible

If the type is `open-question`, the question must surface in the README's projected `### Open questions` section. It must never be hidden — visibility over tidiness; archival demotes the *done*, never the *undecided*.

`rollup` regenerates `### Open questions` from the `open-question`/`question-resolved` filename set, so the question will appear there on the next `rollup` regardless. But don't make visibility wait on a rollup: live-add the bullet to `### Open questions` now (between the projected-zone markers), mirroring how `park` live-adds to `### Open follow-ups`. The bullet **must carry its `Q`-ID** so it can be matched at resolution, in the standard format:

```
- Q<n> — <question>  (raised <YYYY-MM-DD>, still open)
```

If the section reads `_None yet._`, **replace** that line with the new bullet (don't append beneath it). A live edit and a later rollup stay consistent because both derive from the same `open-question-Q<n>` filenames.

If the projected-zone markers are missing, warn and ask before touching the README — don't reconstruct it.

For `decision` and `note` types, the README is not touched here; `rollup` folds them into the projected zone when it next runs.

### 6. Resolution path (settling a raised question)

When Stu's text settles an already-raised question (step 2 routed here), there's no new verb — the `Q<id>` in his words is the dispatch signal:

- Identify the `Q<id>` — named explicitly, or matched against the open `### Open questions` bullets / the `…-open-question-Q<n>.md` filenames.
- Write a resolution Log event `log/YYYY-MM-DDTHH-MM-question-resolved-Q<n>.md` from `${CLAUDE_SKILL_DIR}/templates/log-entry.md` (event type `question-resolved:Q<n>`): what was decided, one line of why, the pointer.
- Remove the `Q<n>` bullet from the README's `### Open questions` section (between the markers) — it drops off the live view but lives in the Log forever.
- Commit `box: question-resolved Q<n> <slug>` (commit-before-edit applies as below).

If you can't confidently match the text to a single `Q<id>`, ask rather than guess — resolving the wrong question is a silent error.

### 7. Commit

Commit-before-edit applies (snapshot `box: snapshot before note`, then write). The final commit is `box: note <slug>` — or `box: question-resolved Q<n> <slug>` for a resolution.

### 8. Report

One line: the type recorded (`decision` / `open-question` / `note`) and the event filename. For an `open-question`, surface the assigned `Q`-ID and add that it's now visible in the README's `### Open questions` and will persist there until resolved. For a resolution, name the `Q<id>` settled and note it's dropped off the live view.

## Notes

The park-vs-note line, drawn clearly:

- **`park`** — an actionable follow-up. It carries a **disposition** naming where it goes (`in-scope-later` / `→ issue` / `→ new box` / `dropped`), gets a permanent `F<id>`, lands under `follow-ups/` (its own `F<id>.md`), and may spin off a carry-forward handoff. At `close` it must reconcile to a terminal disposition. Park is for *work that still needs doing or routing*.
- **`note`** — provenance into the Log. No disposition, no `F<id>`, no handoff, nothing to reconcile at `close`. Note is for *something worth remembering*, not something to do.

The test: if it needs to be done or routed somewhere, it's a `park`. If it just needs to be remembered, it's a `note`. A decision you've already made is a `note` (`decision`); a decision you still have to make is usually an `open-question` note, and only becomes a `park` once acting on it is itself a unit of work.

An `open-question` note is the one type with README presence — because an undecided thing left invisible is the failure mode the box exists to prevent. Everything else in the Log waits for `rollup` to project it.

**Resolution is conversational, not a verb.** A question gets a `Q`-ID at creation and is settled by a `question-resolved:Q<id>` Log event — but there's no `resolve` subcommand. When Stu's text answers a standing question, the `Q<id>` he names (or the question he clearly settles) is the dispatch signal; `note` writes the resolution event and drops the bullet. This mirrors `park`'s `F`-IDs: an ID assigned once, never reused, carried through to its terminal event.
