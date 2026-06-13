# Protocol: note

Log a decision, discovery, or open question. `note` is the lighter sibling of `park`: no disposition, no follow-up entry, no handoff, no `F<id>`. Just a durable log event — something worth remembering that isn't an actionable follow-up.

Use it for the thing you'll want to know *why* about in five days: a choice made, a fact discovered, a question you can't yet answer. If the thing is actionable and needs routing, it's a `park` (see Notes).

## Args

`note <text>`

- With text: classify and write the note.
- Without text: ask what to record. Don't auto-scan the session — a note is a deliberate act of judgement about what's worth keeping, not a digest of everything that happened.

## Steps

### 1. Resolve

Resolve the box root per SKILL.md. If it's genuinely ambiguous, ask.

### 2. Classify

Infer the log event type from the text. Confirm only if genuinely ambiguous.

- `decision` — a choice made. "We'll treat the PR as source of truth." "Dropping SQLite support."
- `open-question` — an unresolved question. "Still don't know how to handle multi-region failover."
- `note` — a discovery or observation that's neither. "Turns out the worker already retries on 429."

When the text reads like both a decision and its reasoning, prefer `decision`. When it ends in a question or names something unknown, prefer `open-question`.

If the text instead **settles** a question already raised — Stu names a `Q<id>` or clearly answers a standing open question — this is a resolution, not a new event type. Skip to step 6.

### 3. Assign a Q-ID (open-question only)

Per the ID rules in SKILL.md: scan the `log/` filenames (both `…-open-question-Q<n>.md` and `…-question-resolved-Q<n>.md`) for the highest existing `Q`-number; the new ID is max + 1, or `Q1` if none exist. The filenames are the authority; the README is a lagging view.

### 4. Write the log event

Create `log/YYYY-MM-DDTHH-MM-<type>.md` from `${CLAUDE_SKILL_DIR}/templates/log-entry.md`, where `<type>` is `decision`, `note`, or — for a question — `open-question-Q<n>`. Fill it:

- **When:** the ISO datetime.
- **What changed:** the decision / question / observation in one line, plus one line of context — enough to stand alone in five days.
- **Artefact:** a pointer if there is one (a file, a PR ref, an item); otherwise "—".
- **Context:** one line of why it matters or how it surfaced.

Keep it 5–20 lines. The log is append-only — never edit an event after writing it.

### 5. Open questions stay visible

If the type is `open-question`, the question must appear in the README's projected `### Open questions` section — an undecided thing left invisible is the failure the box exists to prevent.

`rollup` regenerates that section from the log filenames, so the question would appear on the next rollup regardless — but don't make visibility wait: live-add the bullet now (between the projected-zone markers), mirroring how `park` live-adds to `### Open follow-ups`. The bullet **must carry its `Q`-ID** so it can be matched at resolution:

```
- Q<n> — <question>  (raised <YYYY-MM-DD>, still open)
```

If the section reads `_None yet._`, **replace** that line with the new bullet. If the markers are missing, warn and ask before touching the README.

For `decision` and `note` types, the README is not touched here; `rollup` folds them in when it next runs.

### 6. Resolution path (settling a raised question)

When Stu's text settles an already-raised question, there's no new verb — the `Q<id>` in his words is the routing signal:

- Identify the `Q<id>` — named explicitly, or matched against the open `### Open questions` bullets / the `…-open-question-Q<n>.md` filenames.
- Write `log/YYYY-MM-DDTHH-MM-question-resolved-Q<n>.md` from the log-entry template (event type `question-resolved:Q<n>`): what was decided, one line of why, the pointer.
- Remove the `Q<n>` bullet from the README's `### Open questions` section — it drops off the live view but stays in the log forever.
- Commit `box: question-resolved Q<n> <slug>`.

If you can't confidently match the text to a single `Q<id>`, ask rather than guess — resolving the wrong question is a silent error.

### 7. Commit

Per the commit contract in SKILL.md: snapshot `box: snapshot before note`, then write, then commit `box: note <slug>` — or `box: question-resolved Q<n> <slug>` for a resolution.

### 8. Report

One line: the type recorded and the event filename. For an `open-question`, surface the assigned `Q`-ID and note it's now visible in the README until resolved. For a resolution, name the `Q<id>` settled.

## Notes

- **The park-vs-note test:** if it needs to be done or routed somewhere, it's a `park` (disposition, permanent `F<id>`, reconciled at `close`). If it just needs to be remembered, it's a `note`. A decision already made is a `decision` note; a decision still to be made is usually an `open-question`, and becomes a `park` only once acting on it is itself a unit of work.
- An `open-question` note is the one type with README presence; everything else waits for `rollup`.
- **Resolution is conversational, not a verb.** There is no `resolve` subcommand; the `Q<id>` Stu names (or the question he clearly settles) routes to the resolution path.
