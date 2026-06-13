# Protocol: park

Capture a follow-up with a disposition; if it's a future-session thing, also write a carry-forward handoff. Then hand Stu back to his thread.

Park is usually used at a session boundary: commit what exists, then write a prompt to resume later. Keep capture cheap: Stu types one line; fill in everything else from the session. Ask at most one clarifying question.

## Args

`park <text>` — the one line Stu types when something surfaces. Free text; the disposition may be implicit in it.

- With text → capture from it; infer the disposition; fill in the rest from the session.
- Without text → ask the one line: "What do you want to park?" Don't auto-scan the session for things to park — a park is a deliberate act of judgement.

## Steps

### 1. Resolve and read

Resolve the box root per SKILL.md. Determine the next follow-up ID by listing `follow-ups/F*.md` — the next ID is (highest existing F-number) + 1, per the ID rules in SKILL.md. Single digit is fine; no zero-padding.

If `follow-ups/` doesn't exist, this is the first park — create the directory now. Each follow-up is its own file `follow-ups/F<id>.md`; there is no aggregate follow-ups file.

### 2. Fill in the origin from the live session

Before writing, reconstruct from context — this is what keeps capture cheap. From the live session, work out:

- **Why it surfaced** — what Stu was doing when this came up. One line, written so it makes sense in five days without re-discovery.
- **Key facts** — the 2–3 facts that make the follow-up legible later. Not a transcript; the few things a fresh session can't re-derive cheaply.
- **Recommendation** — if you have one. Optional.

Stu supplies the one line; you fill the rest. Ask only if the intent is genuinely unrecoverable from context.

### 3. Set a disposition — cheaply

Every park gets a disposition (per SKILL.md: `in-scope-later` / `→ issue` / `→ new box` / `dropped`) — a decision about where it goes, not an open-ended "maybe later". `dropped` requires a one-line reason in the entry.

Infer the disposition from the text when you can; ask one line only when it's genuinely unclear. If Stu's text already names a fate ("bin it", "we'll do this in a later session", "raise it as an issue"), take the disposition from it and don't ask.

### 3a. Snapshot

Steps 4–8 are all edits, so snapshot first per the commit contract in SKILL.md (`box: snapshot before park`).

### 4. Write the follow-up entry

Write `follow-ups/F<id>.md` from `${CLAUDE_SKILL_DIR}/templates/follow-up.md`:

```markdown
# F<id> · <title>   <date>  [<disposition>]
**Why it surfaced:** <from step 2>
**Key facts:** <the 2–3 from step 2>
**Recommendation:** <if any; omit the line if none>
**Dead ends:** <approaches already ruled out, if any; omit the line if none>
**Confidence:** loosely-held | firm
```

`<date>` is today, `YYYY-MM-DD`. For a `dropped` disposition, fold the one-line reason into **Why it surfaced** or **Recommendation** so the kill is on the record. If you ruled out an approach while surfacing this, record it in **Dead ends** — without it a fresh session re-walks the same dead path.

### 5. Offer a carry-forward handoff

If the disposition points at a future session — `→ new box`, or an `in-scope-later` item Stu will pick up in a dedicated session — offer in one line to write the carry-forward prompt now: "Want a carry-forward prompt for this?"

If yes, use the format from `${CLAUDE_SKILL_DIR}/protocols/handoff.md` — don't reinvent it. The carry-forward prompt *is* a handoff, just scoped to this one parked thing rather than the full box state. Write it to `handoffs/` (create the directory if absent) as:

```
handoffs/YYYY-MM-DDTHH-MM-<short-slug>.md
```

`<short-slug>` is a kebab-case identifier for the parked work (e.g. `loader-version-mismatch`). Follow `protocols/handoff.md` for the RESUME PROTOCOL, Suggested skills, and State at handoff sections. Reference source artefacts (the box README, the `follow-ups/F<id>.md` entry) by path rather than duplicating them. Redact any secrets. Carry the follow-up's **Dead ends** into the handoff's `Dead ends / do-not` field so the resuming session doesn't re-walk them.

Then log a `handoff` event pointing at the file (step 8). If Stu declines, skip — the follow-up still stands; the prompt can be written later.

### 6. If `→ issue` — draft, never post

Draft a public GitHub issue for the parked thing. The public-leak rule in SKILL.md applies in full: plain English a stranger would understand, none of the box's internal vocabulary, and assume the issue is world-readable.

Present the drafted title + body to Stu in chat. **Draft only — never run `gh issue create` unprompted** (Stu's standing rule). Record the link the other way: note inside the `F<id>` entry that it's been drafted (and, once it exists, the issue ref) — the box side may reference the issue freely.

### 7. Live-update the README

Add the follow-up to the projected zone's `### Open follow-ups` section — one line: `F<id>`, a one-line summary, and the disposition. This mirrors the format `rollup` regenerates from `follow-ups/`, so a live edit and a later rollup stay consistent. If the section reads `_None yet._`, **replace** that line with the new entry. Only touch content between the projected-zone markers (per SKILL.md); if they're missing, warn and don't reconstruct.

### 8. Log

Create `log/YYYY-MM-DDTHH-MM-followup-parked-F<id>.md` from `${CLAUDE_SKILL_DIR}/templates/log-entry.md` (event type `followup-parked:F<id>`; the `:` becomes `-` in the filename per SKILL.md). One event per park, or a single event covering several parked together (filename `…-followup-parked-F<id>-F<id>.md`). Name the disposition and point at `follow-ups/F<id>.md`.

If a carry-forward prompt was written in step 5, also write its `handoff` log event per `protocols/handoff.md` — don't re-specify it here.

### 9. Commit

The snapshot was taken at step 3a. Now commit the park itself: `box: park F<id>`.

### 10. Return Stu to his thread

The happy path is near-silent: **one line** confirming the `F<id>` and its disposition, plus the `handoffs/` path if one was written. No recap, no interview. Then get out of the way.

```
Parked F3 [→ new box] — worker backpressure rewrite. Carry-forward: handoffs/2026-06-04T14-22-worker-backpressure.md
```

## Notes

- **park vs note.** `park` is the heavier sibling: it requires a disposition and may also write a handoff — it's for an actionable thing that goes somewhere. `note` is a bare log entry — a decision, discovery, or open question with no disposition. If the thing has nowhere to go, it's a `note`.
- If you find yourself asking a second clarifying question, the capture has become too expensive — write what you have.
