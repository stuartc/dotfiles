# Protocol: handoff

Write a standalone carry-forward prompt that a fresh session can act on immediately. `handoff` commits the current state, composes the document, writes it into the box's `handoffs/` directory, and logs the event. `park` may invoke the same mechanism for future-session dispositions; `handoff` is the canonical producer.

## Args

`handoff [text]` — optional steer.

- With text → use it as extra context when composing (e.g. the next session's intended focus, a specific concern to emphasise).
- Without text → compose from the current box and session state. Ask only if the intent is genuinely unrecoverable from context.

## Steps

### 1. Resolve and read

Resolve the box root per SKILL.md. Read:

- The full `README.md` static zone (prize, origin, repo facts) and the projected zone.
- The **track** (ordered items + states), and the `items/<id>/` folders for any items in play — each item's `spec.md` and/or `plan.md`.
- Open entries under `follow-ups/` (if the folder exists).
- The last several `log/*.md` filenames, plus the bodies of the ~3–5 most recent.

This is more depth than `status` reads — the handoff must stand alone without the session, so it needs the substance, not just the head.

### 2. Snapshot

Per the commit contract in SKILL.md (`box: snapshot before handoff`).

### 3. Compose the handoff document

The document must be **self-contained** — no "as discussed earlier", no references to the live session. A fresh session with only this file and the box must be able to orient and act.

Structure:

---

```markdown
---
type: handoff
date: <YYYY-MM-DD>
box: <slug>
box-path: <full path to box root>
---

# Handoff: <short-slug>

## RESUME PROTOCOL

This handoff lives inside a box. To resume with full vocabulary loaded:

1. Open a fresh Claude Code session in the project root.
2. Run: `/box` (to load the box skill)
3. Then: `box is here: <full path to box root>` and run `box pickup` — or `box open <box-path>` for a general re-entry without acting on this specific handoff.

Box vocabulary will load automatically. Do not try to interpret this handoff without the box skill loaded.

> Note: this handoff lives in a private box (`handoffs/` is not public). The box's internal vocabulary (`F<id>`, `Q<id>`, slugs, `plan.md` pointers) is safe to use here. If this handoff were ever forwarded to a **public surface**, it would need to be translated into plain English first.

## Purpose

<one paragraph: what this box is working toward and what this specific handoff is handing off>

## Ordered reads

Read these first, in order, before acting:

1. `README.md` — prize, state, next moves (the `## Track`)
2. `items/<id>/` for the in-play items — each item's `spec.md` and/or `plan.md`
3. `follow-ups/` — open parked follow-ups, one `F<id>.md` each (if it exists)
4. <any specific log entries worth calling out, by filename>

## State at handoff

**Done** — already in the tree (committed, or staged/unstaged — be explicit):

- <item>

**Todo** — what the next session does next:

- <item>  `[ready]`
- <item>  `[needs-discovery]`

Open follow-ups that are still live:
- F<id> — <summary>  [<disposition>]

Open questions still unresolved:
- Q<id> — <question>

**Dead ends / do-not** — approaches already ruled out; do not re-walk these:

- <approach tried> — <why it failed / why it's wrong>

**Validation evidence** — the test/lint/build output that confirms the "Done" items above actually hold:

- <command run> → <result, e.g. "42 passing, 0 failures" / "dialyzer clean">

## Concrete work to do next

<one or two paragraphs describing the actual next action, crisp enough that a fresh session could pick it up without re-discovery>

## Suggested skills

- `box` — vocabulary is already loaded (this is a box-aware pickup); use `box plan next`, `box park`, `box note` etc.
- <other skill> — <one-line reason why it's needed>

<Omit this section if no non-box skills are needed.>
```

---

**Dead ends / do-not** records approaches already ruled out and why — without it a fresh session re-walks the same dead paths. **Validation evidence** is the concrete output (test counts, lint status) proving the Done items are real, not assumed. Both may read `_None._` if genuinely empty.

Fold any trailing `[text]` steer into the Purpose or Concrete-work section. Don't invent structure for it.

Keep the document 30–80 lines: long enough to stand alone, short enough to read in 90 seconds.

### 4. Derive a slug and write the file

From the handoff content, derive a `<short-slug>` — kebab-case, 2–4 words, naming what's being carried forward (e.g. `loader-version-mismatch`, `plan-phase-3`). Not the box slug itself.

Create `$BOX_ROOT/handoffs/` if it doesn't exist. Write to:

```
handoffs/YYYY-MM-DDTHH-MM-<short-slug>.md
```

### 5. Append the log event

Create `log/YYYY-MM-DDTHH-MM-handoff.md` from `${CLAUDE_SKILL_DIR}/templates/log-entry.md`: event type `handoff`, artefact pointer to the `handoffs/…` file, one line naming what's being handed forward. 5–10 lines.

### 6. Commit

`box: handoff <slug>`.

### 7. Report

Two lines:

```
Handoff written: handoffs/<filename>
Next session: load the box skill and run `box pickup` (or `box open <path>`).
```

No recap of the handoff body. The file is the artefact.

## Notes

- **Standalone is non-negotiable.** A session reading this file cannot reach back into the conversation history. The RESUME PROTOCOL section must instruct loading the box skill — otherwise a fresh session stumbles over `box plan`, `F<id>`, and projected-zone markers.
- Box vocabulary is safe inside a handoff (`handoffs/` is private); a public forward would need translation per the public-leak rule in SKILL.md.
