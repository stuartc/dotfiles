# Protocol: status

Print current investigation state without editing anything. Read-only orientation for fresh sessions or quick check-ins.

## Args

`status` — no args.

## Steps

### 1. Resolve

Find the investigation root. If multiple recent investigations exist and no clear context, list them and ask.

### 2. Read

- `README.md` (just the projected zone)
- `theories/*/brief.md` frontmatter
- Last 10 `log/*.md` (just titles)

Do not read every file. The point of status is fast orientation — under a second of reading.

### 3. Compose the report

Print to the conversation (do not write to any file):

```
Investigation: <slug>
Created: <date from log/*-intake.md>
Path: <full path>

Theories (N):
  T01 falsified   pod-collision
  T02 confirmed   process-events-race
  T03 proposed    retention-wipe
  T04 probing     async-publish-race

Probes: NN total. Latest: <NN.<ext>> (<theory ref>)

Last 10 events:
  2026-05-27T13:52  theory-confirmed:T02
  2026-05-27T11:30  probe-run:08
  ...

Scope: <headline from scope.md, or "not scoped">
Shapes: A, B, C, X    (or "not categorised")
Fix spec: drafted | not drafted
```

### 4. Suggest next steps

Based on the state:

- No theories yet → suggest `hypothesise`
- All theories proposed, none probed → suggest `probe T<id>` for the one with cheapest evidence
- One confirmed, no fix-spec → suggest `fix-spec T<id>`
- Multiple falsified, none confirmed → suggest `hypothesise` again, or scope re-think
- Stale (no recent events) → suggest a quick `rollup` then continue

Phrase as one or two questions: "Want me to probe T03 next?" — short, optional, easy to redirect.

## Notes

`status` never writes, never commits, never dispatches subagents. It's a thinking-out-loud command. If the user wants to *do* something based on the status, they fire the next subcommand.
