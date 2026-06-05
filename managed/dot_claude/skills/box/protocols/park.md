# Protocol: park

**The headline gesture.** Capture a follow-up with a disposition; if it's a future-session thing, fuse in a carry-forward prompt so resuming is cheap. Then hand Stu back to his thread.

Park is a **session boundary**, not a mid-flow micro-eject. The dominant real behaviour it encodes is *commit what we have, then write a prompt to resume in another session*. The friction budget at the capture moment is the whole ballgame: Stu supplies one line, the protocol fills the rest from the live session. Infer, don't interrogate.

## Args

`park <text>` — the one line Stu types when something surfaces. Free text describing the thing to park; the disposition may be implicit in it.

- With text → capture from it; infer the disposition; backfill everything else from the session.
- Without text → ask the one line: "What do you want to park?" Don't auto-scan the session for things to park — a park is a deliberate act of judgement.

## Steps

### 1. Resolve and read

Resolve the box root per the contract (`.context/stuart/boxes/<slug>/`, or the box Stu pointed at, or the most-recently-modified box). Read `follow-ups.md` if it exists, to find the highest existing `F<id>` — the next ID is +1. IDs are never reused, never renumbered. Single digit is fine; no zero-padding.

If `follow-ups.md` doesn't exist, this is the first park — create it from the header in `${CLAUDE_SKILL_DIR}/templates/follow-up.md` (the `# Follow-ups` heading and the two italic preamble paragraphs, down to the `---`), then append the entry below.

### 2. Backfill origin from the live session

Before writing, reconstruct from context — this is what keeps the friction budget low. From the live session, work out:

- **Why it surfaced** — what Stu was doing when this came up: the Plan item, the question, the line of work it came off. One line, written so it makes sense in five days with no re-discovery.
- **Load-bearing facts** — the 2–3 facts that make the follow-up legible later. Not a transcript; the few things a fresh session can't re-derive cheaply.
- **Recommendation** — if you have one. Optional.

Stu supplies the one line; you fill the rest. Ask only if the intent is genuinely unrecoverable from context. No interrogation on the happy path.

### 3. Force a disposition — cheaply

Every park names where it goes. Disposal language, not deferral. Infer the disposition from the text when you can; ask **one line only** when it's genuinely unclear:

- `in-scope-later` — do during this box, on the tail.
- `→ issue` — becomes a public GitHub issue, provenance linked back (step 6).
- `→ new box` — its own body of work, later.
- `dropped` — explicitly killed. **Requires a one-line reason** in the entry.

If Stu's text already speaks disposal ("bin it", "we'll do this in a later session", "raise it as an issue"), take the disposition from it and don't ask.

### 4. Write the Follow-up entry

Append to `follow-ups.md` using the heavy grain from `${CLAUDE_SKILL_DIR}/templates/follow-up.md`:

```markdown
### F<id> · <title>   <date>  [<disposition>]
**Why it surfaced:** <backfilled origin from step 2>
**Load-bearing facts:** <the 2–3 from step 2>
**Recommendation:** <if any; omit the line if none>
**Confidence:** loosely-held | firm
```

`<date>` is today, `YYYY-MM-DD`. For a `dropped` disposition, fold the one-line reason into **Why it surfaced** or **Recommendation** so the kill is on the record.

### 5. Carry-forward fusion

If the disposition is a **future session** — `→ new box`, or an `in-scope-later` item Stu will pick up in a dedicated session — **offer in one line** to generate the carry-forward prompt now: "Want a carry-forward prompt for this?"

If yes, reuse the **`handoff` skill's format** — don't reinvent it. The carry-forward prompt *is* a handoff scoped to this box; the only difference is where it's persisted. Write it to the box's lazily-created `handoffs/` subdir (create it now if absent) as:

```
handoffs/YYYY-MM-DDTHH-MM-<short-slug>.md
```

`<short-slug>` is a kebab-case identifier for the parked work (e.g. `loader-version-mismatch`). Compose the body per `handoff`'s SKILL.md: a "Suggested skills" section (each with a one-line reason), and a "State at handoff" section splitting **Done** (already in the tree) from **Todo** (what the next session does). Reference source artefacts (the box README, the `F<id>` entry) by path rather than duplicating them. Redact any secrets. The prompt is scoped to *this one parked thing*, not the whole box.

Then log a `handoff` event pointing at the file (step 8). If Stu declines, skip — the follow-up still stands; the prompt can be generated later.

### 6. If `→ issue` — draft, never post

Draft a public GitHub issue for the parked thing. Leak-free is non-negotiable (see "Public artefacts never leak the box" in `SKILL.md`):

- Plain English a stranger to the notes would understand. **None** of the box's internal vocabulary — no `F<id>`, no slug, no "the box found…", no `follow-ups.md` pointers.
- The context repo is private and most of the code is open source — assume the issue is world-readable.

Present the drafted title + body to Stu in chat. **Per Stu's standing rule, draft only — never run `gh issue create` unprompted.** Create it only if he explicitly says so. Record provenance the other way: note inside the `F<id>` entry that it's been drafted (and, once it exists, the issue ref) — the box side may reference the issue freely.

### 7. Live-update the README

Add the follow-up to the projected zone's `### Open follow-ups` section — one line: `F<id>`, a one-line summary, and the disposition. This mirrors the format `rollup` regenerates from `follow-ups.md`, so a live edit and a later rollup stay consistent. If the section reads `_None yet._`, **replace** that line with the new entry (don't append beneath it). Only touch content between the `<!-- BOX: BEGIN PROJECTED -->` / `<!-- BOX: END PROJECTED -->` markers; if they're missing, warn and don't reconstruct.

### 8. Log

Append a `followup-parked:F<id>` Log event from `${CLAUDE_SKILL_DIR}/templates/log-entry.md` — one event per park, or a single event covering several if they were parked together (`followup-parked:F<id>,F<id>`). Name the disposition and point at `follow-ups.md`.

If a carry-forward prompt was written in step 5, append a separate `handoff` Log event pointing at the `handoffs/` file.

### 9. Commit

Commit-before-edit applies. Before editing, stage and commit the current state — `box: snapshot before park`. If the working tree has unrelated changes, stop and ask rather than sweeping them in. `.context/` is usually its own git repo (often a symlink) — resolve the repo root via `readlink -f .context` and run git with `git -C <repo> …`; do **not** `cd` into the target. After applying the edits, `git -C <repo> add -A` and `git -C <repo> commit -m "box: park F<id>"`.

### 10. Return Stu to his thread

The happy path is near-silent: **one line** confirming the `F<id>` and its disposition, plus the `handoffs/` path if one was written. No recap, no interrogation. Then get out of the way — Stu goes back to what he was doing.

```
Parked F3 [→ new box] — worker backpressure rewrite. Carry-forward: handoffs/2026-06-04T14-22-worker-backpressure.md
```

## Notes

- **park vs note.** `park` is the heavier sibling: it forces a disposition and may fuse in a handoff — it's for an actionable thing that goes somewhere. `note` is a bare Log entry — a decision, discovery, or open question with no disposition. If the thing has nowhere to go, it's a `note`, not a `park`.
- **Park is a session boundary, not a micro-eject.** Its dominant use is *commit, then write a prompt for another session*. The carry-forward fusion (step 5) is the whole reason park is heavier than triage's `followup`.
- **The friction budget is the point.** Stu supplies one line; the protocol backfills origin, infers the disposition, and writes the entry. Ask one line for the disposition only when genuinely unclear — never run an interview. If you find yourself asking a second question, you've broken the gesture.
- **Cross-protocol.** `close` reconciles every open follow-up to a terminal disposition — a parked `in-scope-later` or `→ new box` is expected to land there. `rollup` regenerates the `### Open follow-ups` section from `follow-ups.md`; the step-7 live edit just keeps the README current between rollups.
