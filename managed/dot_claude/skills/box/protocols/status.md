# Protocol: status

Print the current box state without editing anything. Read-only — a quick re-orient when the box is already open this session. (`open` is for the start of a session; it resolves and loads the box first.)

## Args

`status` — no args.

## Steps

### 1. Resolve

Resolve the box root per the rule in SKILL.md. If multiple recent boxes exist and there's no clear context, list them and ask.

### 2. Read

Read only — fast orientation:

- `README.md` — just the projected zone (`## Where things stand`, between the markers).
- The **track** — the ordered item list with states. Item bodies live under `items/<id>/`; don't open them.
- Open entries under `follow-ups/` (if the folder exists).
- The last ~5–10 `log/*.md` filenames (titles only — don't open the bodies).

Do not read every file. If the projected-zone markers are missing, say so and fall back to whatever the README shows; don't reconstruct.

**Open-question count: use the projected zone.** `status` reads only the last ~5–10 `log/` filenames, so a `question-resolved-Q<n>` event in a long-lived box can fall outside that window and make a settled question look open. The projected zone (from the last rollup) is the source of truth for the open-question count here. If the projection looks stale, suggest `box rollup` — it scans the full `log/` set (raised minus resolved) and refreshes the projection.

### 3. Compose the report

Print to the conversation (never to a file):

```
Box: <slug>
Created: <date from the `born` log event>
Path: <full path>

State: <the one-line state>

Next moves:
  <next track item>
  <next track item>   needs-discovery
  ...

Open follow-ups:
  F1  loader swallows version mismatches    in-scope-later
  F2  retire the legacy CLI flag            → issue
  ...

Open questions:
  Q1  <unresolved question>
  ...

Recent activity (last ~5–10):
  2026-06-04T09-10  born
  2026-06-04T11-32  followup-parked:F1
  ...
```

Call out `needs-discovery` items explicitly — they're not actionable until specced. If a section is empty, say so in one line rather than printing an empty heading.

### 4. Suggest next steps

Offer one or two short, optional questions — terse and easy to wave off:

- No items ready → suggest `box spec <id>` for the next `needs-discovery` item, or `box plan` to flesh out the track.
- A `ready` item exists → "Want to pick up <item>?" (`box do <id>`).
- The projected zone looks out of sync with the source files → suggest `box rollup`.
- Lots of open follow-ups → flag that they'll need reconciling at `box close`.

If the user wants to act on the status, they fire the next subcommand.

## Notes

`status` never writes, never commits, never dispatches subagents.
