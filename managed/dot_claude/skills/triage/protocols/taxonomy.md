# Protocol: taxonomy

Categorise error shapes when a single Sentry bucket / log pattern is lumping multiple distinct problems.

## When to use

- A Sentry issue with a generic error message that masks several underlying causes
- Logs that share a header line but diverge in stack or context
- Any time you find yourself saying "actually there are several flavours of this"

Skip taxonomy if there's clearly only one shape.

## Args

`taxonomy` — no required args. Extra text after subcommand is steer for the agent.

## Steps

### 1. Resolve and read

Find the investigation root. Read `references.md`, `README.md`, and `scope.md` if it exists.

### 2. Dispatch a taxonomy subagent

Brief:

> Categorise the error shapes for the bug in `<investigation root>/`.
>
> Read `references.md`, `README.md`, `scope.md` for context.
>
> Produce `<investigation root>/shapes.md` with:
>
> - **Naming convention** — assign single-letter or short-word shape names (A, B, C, X). X is conventionally the "doesn't fit, needs more data" bucket. Keep names short — they're used verbatim everywhere downstream.
> - **One section per shape** — for each shape:
>   - The diagnostic signature (error message pattern, stack snippet, context fields)
>   - Sample event IDs / run IDs / log line refs that exemplify it
>   - Approximate count or proportion
>   - Notes on what makes this shape distinct from the others
> - **Overlaps** — any cases where a single event could match multiple shapes, and the disambiguation rule
> - **Sources** — queries / MCP calls used
>
> **Discovery first.** If you need to read events from Sentry, do one list call to confirm the fields you need are present in the list response. If `run_id` (or any other key field) is only available in per-event detail, sample 5–10 events and stop — do not paginate through hundreds. Document the field availability constraint in shapes.md.
>
> **Sample, don't enumerate.** For a shape with N occurrences, pick 3–5 representative samples. Burst patterns (one run, 150 events) collapse to one sample.
>
> Return ≤5 lines: shape names + one-line signature each.

Append user's extra steer to the brief.

### 3. Read and sanity-check

Open `shapes.md`. Verify each shape has a real diagnostic signature, not a tautology like "Shape A is the cases that aren't Shape B". Re-dispatch if not.

### 4. Update README

In the projected zone, add a `## Shapes` section listing shape names + one-line signatures. Link to `shapes.md` for detail.

### 5. Log

Append `log/YYYY-MM-DDTHH-MM-taxonomy-recorded.md`:

```
# Taxonomy recorded

Shapes: A, B, C, X
File: shapes.md

Headline:
- A: <one-line signature>
- B: <one-line signature>
- ...
```

Also log a `shape-discovered:<name>` event for each shape introduced (one file per shape, or list all in the taxonomy event — either is fine, prefer one combined for the initial taxonomy).

### 6. Commit

`triage: taxonomy <slug>`.

### 7. Report

List shape names + signatures. Suggest `hypothesise` next — usually one or more theories per shape.

## Notes

If a new shape is discovered later (not at first taxonomy), don't re-run this command. Instead, edit `shapes.md` directly to add the new shape, and log a `shape-discovered:<name>` event. The taxonomy command is for the initial bulk categorisation; incremental shape additions are normal investigation work.

**Symptom vs cause.** A "shape" with a thin stack (bare DB timeout, generic error, nothing pointing at our code) may be a downstream *symptom* rather than a distinct cause. Before treating it as its own shape worth theorising about, do the bounded correlated look from `init`'s thin-stack exception: same `trace_id` first, tight timestamp window as fallback (≤5 calls). If a richer error on the same trace explains it, fold this shape into that one and note the relationship in `shapes.md` rather than spawning a parallel theory for the symptom.
