# Track item

_A single line in the README **Track** — the index over items. Each item is addressable: its body lives in `items/<id>/`, the README only carries the one-liner + state. Line format: a Markdown checklist line with the state in a trailing `` `[state]` `` tag. The checkbox tracks **completion**; the tag tracks the **lifecycle state**._

```
- [ ] <id> · {{INTENT}}  `[stub]`
- [ ] <id> · {{INTENT}}  `[needs-discovery]`
- [ ] <id> · {{INTENT}}  `[ready]`
- [x] <id> · {{INTENT}}  `[done]`
- [x] <id> · {{INTENT}}  `[superseded]`  _(by <id(s)> — reason)_
```

_`<id>` is the addressable item id (e.g. `D1` for the decomposition item, `1`, `2`, … for work items) — the folder under `items/`._

## States → artefact

| State | Artefact | Meaning |
|---|---|---|
| `stub` | — (no folder yet) | Placeholder on the track. Known to exist, not yet described. |
| `needs-discovery` | `items/<id>/spec.md` | Known but not yet understood. Write the spec; open questions allowed. |
| `ready` | `items/<id>/plan.md` | Crisp and agent-actionable — zero open questions. `box do <id>` can run it. |
| `done` | body moved to `archive/` at close | Complete. Checkbox ticked; dropped from the active track by `box rollup`, body moved to `archive/items/<id>/` by `box close`. |
| `superseded` | body moved to `archive/` at close | **Closed without being built** — its scope was absorbed or replaced by other item(s). Checkbox ticked; carries a `_(by <id(s)> — reason)_` note; same archive path as `done`. |

_The `needs-discovery → ready` transition **is** the spec→plan progression. **Not every item needs both artefacts:** skip the spec (set `stub → ready`) when there's nothing to discover; a review item may be spec-heavy with a thin plan; a mechanical item may be plan-only. The plan is the thing `do` runs against; the spec is what you write when understanding is the risk._
