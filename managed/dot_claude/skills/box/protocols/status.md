# Protocol: status

Print current box state without editing anything. Read-only orientation for fresh sessions or quick check-ins — the conversational front door. Run this and you're loaded, without re-reading the whole box.

## Args

`status` — no args.

## Steps

### 1. Resolve

Resolve the box root per the contract's box-root resolution rule. If multiple recent boxes exist and there's no clear context, list them and ask which one.

### 2. Read

Read only — fast orientation, under a second of reading:

- `README.md` — just the projected zone (`## Where things stand`, between the `<!-- BOX: BEGIN PROJECTED -->` / `<!-- BOX: END PROJECTED -->` markers).
- The **track** — the ordered item list with states, from the README's `## Track` / projected zone. Item bodies live under `items/<id>/`; don't open them.
- The open entries under `follow-ups/` (each `follow-ups/F<id>.md`, if the folder exists).
- The last ~5–10 `log/*.md` filenames (just the titles — don't open the bodies).

Do not read every file. If the projected-zone markers are missing, say so and fall back to whatever the README shows; don't reconstruct.

**Open-question caveat.** `status` reads only the last ~5–10 `log/` filenames, so a `question-resolved-Q<n>` event in a long-lived box can fall outside that window — making a settled question still look open. The projected zone (from the last rollup) is the more reliable source for the count here. If the open-question count looks off, run `box rollup` first — it scans the **full** `log/` set (raised minus resolved) and refreshes the projection.

### 3. Compose the report

Print to the conversation (do not write to any file). Shape it on the README projected zone:

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
  Q1  <unresolved question, still visible>
  Q3  <unresolved question, still visible>
  ...

Recent activity (last ~5–10):
  2026-06-04T09-10  born
  2026-06-04T11-32  followup-parked:F1
  ...
```

Call out `needs-discovery` track items explicitly — they're not actionable until engaged. If a section is empty (no follow-ups, no open questions), say so in one line rather than printing an empty heading.

### 4. Suggest next steps

Based on the state, offer one or two short, optional questions — the "point me at" prompt. Stu redirects easily, so keep them terse and easy to wave off:

- No items ready (all `stub`/`needs-discovery`/`done`) → suggest `box spec <id>` for the next `needs-discovery` item, or `box plan` to flesh out the track.
- A `ready` item exists → "Want to pick up <item>?" (it becomes `box do <id>`).
- Stale, or the projected zone looks out of sync with the source files → suggest `box rollup`.
- Lots of open follow-ups → flag they'll need reconciling at `box close`.

Phrase as a question: "Want to pick up the loader fix?" — short, optional, easy to redirect. If the user wants to *do* something off the back of the status, they fire the next subcommand.

## Notes

`status` never writes, never commits, never dispatches subagents. It's a thinking-out-loud command — read the head, report, suggest. All the doing happens in the other verbs.
