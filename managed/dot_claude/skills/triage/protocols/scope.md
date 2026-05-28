# Protocol: scope

Size the problem before deciding whether to dig deeper.

## When to use

- Before hypothesising, when you don't yet know whether this bug is widespread enough to invest in
- When the reference (Sentry / GH) gives a raw count but you want to know who's affected and over what time range
- Mid-investigation when a stakeholder asks "how big is this?"

Skip scope entirely if it's already obvious — eg. a single customer-reported bug with a known repro.

## Args

`scope` — no required args. Free-text after the subcommand is passed to the dispatched subagent as extra steer.

## Steps

### 1. Resolve the investigation root

Find the active investigation. If multiple exist, ask which. If the current conversation has a clear focus, use that.

### 2. Read what we know

Read `references.md` and the current `README.md`. Note any counts, time ranges, or affected entities already mentioned. The point is to extend, not duplicate.

### 3. Dispatch a scoping subagent

Use `Agent` with `general-purpose` or `web-search-researcher` (if web data is part of scope). Brief shape:

> Scope the bug in `<investigation root>/`.
>
> Read `references.md` and `README.md` for context.
>
> Produce `<investigation root>/scope.md` with these sections:
>
> - **Volume** — occurrence count, broken down by time window (last 24h / 7d / 30d / 90d if data goes that far). Source the numbers (Sentry, DB, logs).
> - **Affected entities** — which projects / users / environments / versions. Names if available, counts if not.
> - **Trend** — rising, falling, flat, bursty. One sentence.
> - **Severity signal** — data loss? user-visible? silent? recoverable? One paragraph.
> - **Sources** — list the queries / MCP calls used so it's reproducible.
>
> **Discovery first.** Before running any long Sentry pagination or large DB query, verify in ≤5 tool calls that the data you need exists in the shape you assume. If counts aren't available as tags on the Sentry issue, say so and stop — don't fall back to fetching every event individually.
>
> Return ≤5 lines: the headline number, the trend, and the severity verdict. Write everything else to the file.

Extra steer text from the user (if any) gets appended to the brief.

### 4. Read the returned file

Open `scope.md`. Sanity-check that the numbers came from named sources. If anything looks like a hallucination or the agent ran a discovery step that failed and proceeded anyway, push back and re-dispatch.

### 5. Update the README's projected zone

Add or update a `## Scope` line in the projected zone with the headline number and trend. Don't paste the whole file in — link to `scope.md`.

### 6. Log

Append `log/YYYY-MM-DDTHH-MM-scope-recorded.md`:

```
# Scope recorded

Headline: <one line — eg. "4,200 occurrences in 7d across 3 projects, rising">
Severity: <one word + one line>
File: scope.md
```

### 7. Commit

Commit-before-edit applies here. Snapshot before the README edit, commit the new files after. Message: `triage: scope <slug>`.

### 8. Report

One paragraph: headline number, trend, severity verdict. Suggest next step — usually `taxonomy` if there are multiple shapes, or `hypothesise` if there's one clean shape.
