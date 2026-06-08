# Protocol: handoff

Write a standalone carry-forward prompt that a fresh session can act on immediately. `handoff` is a **first-class verb** — it commits the current state, composes the document, writes it into the box's `handoffs/` directory, and logs the event. `park` may invoke the same carry-forward mechanism for future-session dispositions; `handoff` is the canonical producer.

## Args

`handoff [text]` — optional steer.

- With text → use it as extra context when composing the handoff (e.g. the intended next session's focus, a specific concern to emphasise).
- Without text → compose from the current box and session state. Ask only if the intent is genuinely unrecoverable from context.

## Steps

### 1. Resolve and read

Resolve the box root per the contract (`.context/stuart/boxes/<slug>/`, or the box the user pointed at, or the most-recently-modified box). Read:

- The full `README.md` static zone (prize, origin, repo facts) and the projected zone.
- The `## Plan` — inline or `plan.md`.
- Open entries in `follow-ups.md` (if it exists).
- The last several `log/*.md` filenames, plus the bodies of the ~3–5 most recent.

This is more depth than `status` reads — the handoff must stand alone without the session, so it needs the substance, not just the head.

### 2. Snapshot commit

Commit-before-edit applies. Check `git -C "$CONTEXT_REPO" status --porcelain`. If the tree has changes, stage and commit: `box: snapshot before handoff`. If the tree has unrelated changes, stop and ask rather than sweeping them in. If the tree is clean, skip the snapshot and proceed.

Resolve the repo root once: `CONTEXT_REPO=$(readlink -f .context)`. Run all git commands with `git -C "$CONTEXT_REPO" …`; do **not** `cd` into the target.

### 3. Compose the handoff document

The document must be **self-contained and standalone** — no "as discussed earlier", no references to the live session. A fresh session with only this file and the box must be able to orient and act.

Structure the document as follows:

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

> Note: this handoff lives in a private box (`handoffs/` is not public). The box's internal vocabulary (`F<id>`, `Q<id>`, slugs, `plan.md` pointers) is safe to use here. If this handoff were ever forwarded to a **public surface**, it would need to be translated into plain English before sending.

## Purpose

<one paragraph: what this box is working toward and what this specific handoff is handing off>

## Ordered reads

Read these first, in order, before acting:

1. `README.md` — the head: prize, state, next moves
2. `<plan.md or inline ## Plan>` — the current work track
3. `follow-ups.md` — open parked items (if it exists)
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

## Concrete work to do next

<one or two paragraphs describing the actual next action, crisp enough that a fresh session could pick it up without re-discovery>

## Suggested skills

- `box` — vocabulary is already loaded (this is a box-aware pickup); use `box plan next`, `box park`, `box note` etc.
- <other skill> — <one-line reason why it's needed>

<Omit this section if no non-box skills are needed.>
```

---

Fold any trailing `[text]` steer from the user into the Purpose or Concrete-work section as additional context. Do not invent structure for it — incorporate it naturally.

Keep the document 30–80 lines. Long enough to stand alone; short enough to read in 90 seconds.

### 4. Derive a slug and write the file

From the box state and the handoff content, derive a `<short-slug>` — kebab-case, 2–4 words, naming what this handoff is handing off (e.g. `loader-version-mismatch`, `plan-phase-3`, `worker-retry-refactor`). Not the box slug itself; what's being carried forward.

Create `$BOX_ROOT/handoffs/` if it doesn't exist. Write the document to:

```
handoffs/YYYY-MM-DDTHH-MM-<short-slug>.md
```

Use today's date and the current time (or a close approximation if the current time is unavailable).

### 5. Append the Log event

Create `log/YYYY-MM-DDTHH-MM-handoff.md` from `${CLAUDE_SKILL_DIR}/templates/log-entry.md`, mapping the template fields: `{{EVENT_TYPE}}` → `handoff`; `{{ISO_DATETIME}}` → now; `{{ARTEFACT_POINTER}}` → the `handoffs/…` file path; `{{WHAT_CHANGED}}` and `{{ONE_LINE_CONTEXT}}` → one line naming what's being handed forward. Don't drop `{{ONE_LINE_CONTEXT}}`. 5–10 lines.

### 6. Commit

After writing, `git -C "$CONTEXT_REPO" add -A` and `git -C "$CONTEXT_REPO" commit -m "box: handoff <slug>"`. No co-author lines, no skip-hooks.

If `.context/` is not a git repo, skip the commit and tell the user.

### 7. Report

Two lines:

```
Handoff written: handoffs/<filename>
Next session: load the box skill and run `box pickup` (or `box open <path>`).
```

No recap of the handoff body. The file is the artefact.

## Notes

- **Standalone is non-negotiable.** A session reading this file cannot reach back into the conversation history. Every pointer is a path or a reference; every claim stands on its own.
- **Box vocabulary is safe inside a handoff.** The `handoffs/` directory is private. `F<id>`, `Q<id>`, slugs, and file-path references are fine. If the handoff were ever forwarded to a public surface, it would need a leak-free translation first — the RESUME PROTOCOL section says as much.
- **The resume protocol matters.** A fresh session without the box skill loaded will not have the box vocabulary. The RESUME PROTOCOL section must explicitly instruct loading the skill — otherwise a naive pickup may stumble over `box plan`, `F<id>`, projected-zone markers, and so on.
- **`park` and `handoff`.** `park` offers the carry-forward prompt for future-session dispositions and writes the same handoff format to `handoffs/`. It points here as the canonical form — it does not duplicate the steps. `handoff` as a first-class verb produces the same artefact without the follow-up entry overhead; use it when you want a carry-forward prompt without a new `F<id>`.
