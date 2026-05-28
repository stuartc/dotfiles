# Protocol: findings

Interpret probe output. Write the verdict for a theory.

## Args

`findings T<id> [extra steer]` — required: the theory ID being assessed. Extra text passed to the dispatched agent.

## Steps

### 1. Resolve and read

Find the investigation root. Confirm `theories/T<id>-*/brief.md` exists.

List the probes that reference T<id> in their header comments — these are the ones the agent should read. Verify each has both a `NN.<ext>` and a `NN.out` (or `NN-test-output.txt` for failing-test probes).

If any expected `.out` is missing, **stop and ask** the user — the probe hasn't been run yet. Don't fabricate findings.

### 2. Dispatch the findings subagent

Brief:

> Interpret probe results for theory T<id> in `<investigation root>/`.
>
> Read:
> - `theories/T<id>-<slug>/brief.md` (especially the falsification + confirmation criteria)
> - Every probe file that references T<id> in its header, with both script and `.out`
>
> Produce `theories/T<id>-<slug>/findings.md` with these sections:
>
> - **Verdict** — exactly one of: `falsified` / `confirmed` / `partially-confirmed` / `inconclusive` / `needs-more-data`
> - **Reasoning** — one or two paragraphs, citing specific probe outputs by file:line or row anchor
> - **Evidence pointers** — bulleted list of `probes/NN.out` references with the relevant excerpt or row count
> - **What this implies for other theories** — if falsifying this theory points at another, or confirming it makes another redundant, name the theory IDs. Don't speculate — only call out direct implications.
> - **Open questions** — anything the probe didn't answer that's still relevant
>
> Stay strictly within the verdict on this theory. Do not propose new theories — that's `hypothesise`. Do not draft a fix — that's `fix-spec`. If the output surfaces a new error shape, mention it in "Open questions" only; the user can decide whether to extend the taxonomy.
>
> Return ≤5 lines:
> - Verdict (one word)
> - One-sentence reasoning
> - One implication for another theory if any
> - Path to findings.md

Append user's extra steer.

### 3. Update the theory brief frontmatter

Set the theory's `status:` field to match the verdict:

| Verdict | Brief status |
|---|---|
| `falsified` | `falsified` |
| `confirmed` | `confirmed` |
| `partially-confirmed` | `partially-confirmed` |
| `inconclusive` | `inconclusive` |
| `needs-more-data` | `probing` |

Don't edit any other part of the brief — the original mechanism + criteria are immutable. The verdict lives in `findings.md`.

### 4. README update

Update the theory's status in the projected zone's `## Theories` list. If the verdict is `confirmed`, also surface it prominently (eg. `## Confirmed root cause`) and link to the findings.

### 5. Log

Append `log/YYYY-MM-DDTHH-MM-theory-<verdict>-T<id>.md` (event type matches verdict — `theory-falsified:T<id>`, `theory-confirmed:T<id>`, `probe-inconclusive:T<id>`):

```
# Theory <verdict>: T<id>

Slug: T<id>-<slug>
Verdict: <falsified | confirmed | partially-confirmed | inconclusive | needs-more-data>
Headline: <one line from findings>
File: theories/T<id>-<slug>/findings.md
Probes: NN[, NN, NN]
```

### 6. Commit

`triage: findings T<id> <verdict>`.

### 7. Report

State verdict + one-line reasoning. Suggest next step:

- `confirmed` → `fix-spec T<id>`
- `falsified` → next theory to probe, or `hypothesise` if all are dead
- `partially-confirmed` → either another probe to nail the rest, or `fix-spec` if the partial confirmation is enough
- `inconclusive` / `needs-more-data` → another probe, possibly a different evidence type

## Supersession

If a finding falsifies T<id> *because* T<jd> better explains the data, log a `theory-superseded:T<id>-by-T<jd>` event in addition to the verdict event. Don't delete or edit T<id>'s brief or findings — supersession is a relationship between theories, not a rewrite of either.
