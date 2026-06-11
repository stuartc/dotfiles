# Protocol: open

Orient to a box: resolve it, check for handoffs, and report the current state. `open` is the **explicit front door for resuming an existing box** across sessions — it resolves the box root, loads vocabulary, detects carry-forward handoffs, and hands orientation back to the user. It does not execute anything.

`open` is to `status` what booting is to running: `open` resolves and loads the box first, then reports. `status` assumes the box is already loaded for the session and skips straight to reporting. Use `open` at the start of a session when you need to locate or name the box; use `status` once it's already established.

## Args

`open [path]` — optional explicit path.

- With a path (`box open <path>`) → use it directly as the box root.
- Also accepts the conversational form: `box is here: <path>` anywhere in the message.
- Without a path → use the most-recently-modified box under `.context/stuart/boxes/`.
- If multiple boxes exist and there's no clear recency signal, list them and ask which one.

## Steps

### 1. Resolve the box root

- If the user gave a path argument or used `box is here: <path>`, use that path.
- Otherwise, find the most-recently-modified box under `.context/stuart/boxes/` (sort by `README.md` modification time or the latest log entry).
- If multiple boxes have nearly-identical recency and there's no contextual signal, list up to five by slug and last-modified date and ask which one.
- Confirm the path resolves to a directory with a `README.md`. If it doesn't exist, say so plainly and offer `box new <slug>` to create it.

This is the box-root-resolution convention: once resolved, this path is `$BOX_ROOT` for the rest of this invocation. Do not re-resolve.

### 2. Read the head

Read — fast orientation, the same read that `status` does:

- The projected zone of `README.md` — the content between the `<!-- BOX: BEGIN PROJECTED -->` / `<!-- BOX: END PROJECTED -->` markers. This is `## Where things stand`.
- The **track** — the ordered item list with states, from the README's `## Track` / projected zone. Item bodies live under `items/<id>/`; don't open them here.
- Open entries under `follow-ups/` (each `follow-ups/F<id>.md`, if the folder exists).
- The last ~10 `log/*.md` filenames (titles only — do not open the bodies).

If the projected-zone markers are missing, say so and fall back to whatever the README shows; do not reconstruct.

### 3. Detect handoffs

Check whether `$BOX_ROOT/handoffs/` exists and is non-empty.

- If **no handoffs/** or it's empty: proceed to step 4.
- If handoffs exist: identify the most recent file (sort by filename — they're timestamped `YYYY-MM-DDTHH-MM-<slug>.md`). Surface it explicitly:

  ```
  Handoff found: handoffs/<filename>
  ```

  Offer `box pickup` to resume from it. One line is enough — don't read the body yet; that's `pickup`'s job. If the most-recent handoff looks like it was written for this specific session's intent (from the slug), note that; otherwise stay neutral.

### 4. Compose and print the orientation report

Print to the conversation — never write to a file. This is the same output shape `status` produces; `open` ends with the same report. Shape it from the README projected zone and the reads in step 2:

```
Box: <slug>
Path: <full path>
Created: <date from the `born` log event>

State: <the one-line state>

Next moves:
  <next track item>  `[ready]`
  <next track item>  `[needs-discovery]`
  ...

Open follow-ups:
  F1  <one-line summary>  [in-scope-later]
  F2  <one-line summary>  [→ issue]
  ...

Open questions:
  Q1  <question>  (raised <date>, still open)
  ...

Recent activity (last ~5–10):
  2026-06-04T09-10  born
  2026-06-04T11-32  followup-parked-F1
  ...
```

Call out `needs-discovery` track items explicitly — they're not actionable until engaged. If a section is empty (no follow-ups, no open questions), say so in one line rather than printing an empty heading.

If a handoff was found in step 3, add a line to the report:

```
Handoff: handoffs/<filename>  — run `box pickup` to resume from it
```

### 5. Suggest next steps

Based on the state, offer one or two short, optional questions. Keep them terse and easy to wave off:

- Handoff detected → "Want to pick up from the handoff (`box pickup`)?"
- No items ready, but `needs-discovery` items exist → suggest `box spec <id>` for the next one (then `box plan <id>` to take it to `ready`).
- A near-empty or all-stub box → steer toward decomposition: `box plan` to sketch the track, or `box spec D1` to work the decomposition item.
- A `ready` item exists → "Want to start on <item> (`box do <id>`)?"
- Stale projected zone or signs of a burst of activity since last rollup → suggest `box rollup`.

Phrase as a question. If the user wants to do something off the back of the orientation, they fire the next subcommand.

## Notes

`open` never writes, never commits, never dispatches subagents. It is purely orientation — the entry point, not the doing.

**`open` vs `status`:** `open` is the front door. It resolves which box to load, checks for handoffs, and then reports. `status` is for mid-session check-ins when the box is already established — it skips resolution and goes straight to the report. When in doubt about which to use: if you're starting a fresh session or picking a box, use `open`; if you're already working in a named box and want a quick re-orient, use `status`.
