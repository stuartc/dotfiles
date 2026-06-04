# Plan item

_A single plan-item snippet. Plan items are intent-level — one line of intent plus a state marker. State convention: a Markdown checklist line, with the state in a trailing `` `[state]` `` tag. The checkbox tracks completion; the tag tracks the lifecycle state._

```
- [ ] {{INTENT}}  `[stub]`
- [ ] {{INTENT}}  `[needs-discovery]`
- [ ] {{INTENT}}  `[ready]`
- [ ] {{INTENT}}  `[in-progress]`
- [x] {{INTENT}}  `[done]`
```

## States

- `stub` — placeholder only; body is `<TODO: spec out>`. Known to exist, not yet described.
- `needs-discovery` — known but not understood. Engage discovery when you reach it (conversational in v1 — no verb).
- `ready` — crisp and actionable. A fresh session could pick it up and run.
- `in-progress` — being worked right now.
- `done` — complete. Checkbox ticked; `box rollup` demotes it out of the active Next-moves view into the Log.
