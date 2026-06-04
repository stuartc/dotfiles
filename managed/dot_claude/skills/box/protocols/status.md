# Protocol: status

Print current box state without editing anything. Read-only orientation for fresh sessions or quick check-ins — the conversational front door. Run this and you're loaded, without re-reading the whole box.

## Args

`status` — no args.

## Steps

### 1. Resolve

Resolve the box root (per the contract's box-root resolution rule): `.context/stuart/boxes/<slug>/` relative to `pwd`, or the box the user pointed at (`box is here: <path>`), or the most-recently-modified box under `.context/stuart/boxes/`. If multiple recent boxes exist and there's no clear context, list them and ask which one.

### 2. Read

Read only — fast orientation, under a second of reading:

- `README.md` — just the projected zone (`## Where things stand`, between the `<!-- BOX: BEGIN PROJECTED -->` / `<!-- BOX: END PROJECTED -->` markers).
- The `## Plan` — inline in the README, or `plan.md` if it has split out.
- The open entries in `follow-ups.md` (if it exists).
- The last ~10 `log/*.md` filenames (just the titles — don't open the bodies).

Do not read every file. If the projected-zone markers are missing, say so and fall back to whatever the README shows; don't reconstruct.

### 3. Compose the report

Print to the conversation (do not write to any file). Shape it on the README projected zone:

```
Box: <slug>
Created: <date from the `born` log event>
Path: <full path>

State: <the one-line state>

Next moves:
  <next Plan item>
  <next Plan item>   needs-discovery
  ...

Open follow-ups:
  F1  loader swallows version mismatches    in-scope-later
  F2  retire the legacy CLI flag            → issue
  ...

Open questions:
  - <unresolved question, still visible>
  ...

Recent activity (last ~5–10):
  2026-06-04T09-10  born
  2026-06-04T11-32  followup-parked:F1
  ...
```

Call out `needs-discovery` Plan items explicitly — they're not actionable until engaged. If a section is empty (no follow-ups, no open questions), say so in one line rather than printing an empty heading.

### 4. Suggest next steps

Based on the state, offer one or two short, optional questions — the "point me at" prompt. Stu redirects easily, so keep them terse and easy to wave off:

- No Plan items ready (all `stub`/`needs-discovery`/`done`) → suggest `box plan`.
- A `ready` item exists → "Want to pick up <item>?" (it becomes `box plan next`).
- Stale, or the projected zone looks out of sync with the source files → suggest `box rollup`.
- Lots of open follow-ups → flag they'll need reconciling at `box close`.

Phrase as a question: "Want to pick up the loader fix?" — short, optional, easy to redirect. If the user wants to *do* something off the back of the status, they fire the next subcommand.

## Notes

`status` never writes, never commits, never dispatches subagents. It's a thinking-out-loud command — read the head, report, suggest. All the doing happens in the other verbs.
