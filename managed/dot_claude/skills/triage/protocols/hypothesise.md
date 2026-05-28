# Protocol: hypothesise

Propose theories. One brief per theory, falsification criterion required.

## Args

`hypothesise [free text describing one theory]` — text is optional. If present, create a single theory from the text. If absent, dispatch a subagent to read the current investigation state and propose multiple.

## Steps

### 1. Resolve and read

Find the investigation root. Read `README.md`, `references.md`, `scope.md`, `shapes.md` (if they exist), and `theories/*/brief.md` for any already-proposed theories — so we don't duplicate.

### 2. Decide the path

**Free-text mode** (user gave a theory in args): proceed to step 3, create one theory.

**Dispatch mode** (no args): dispatch a subagent with:

> Propose theories for the bug in `<investigation root>/`.
>
> Read `README.md`, `references.md`, `scope.md`, `shapes.md`, and every `theories/*/brief.md` that already exists.
>
> Propose 2–5 plausible theories. For each:
>
> - One sentence stating the proposed mechanism
> - The falsification criterion — what specific observation would rule it out
> - The cheapest evidence type that could test it (SQL probe, IEx, code reading, failing test, log grep, Sentry filter)
> - Which shape(s) it explains, if shapes are defined
>
> Return as a numbered list, one paragraph per theory. Do not write any files — the main session will create the theory folders.

When the subagent returns, Stu picks which to instantiate (the main session asks). For each selected theory, proceed to step 3.

### 3. Assign the next theory ID

List `theories/` and find the highest existing `T<NN>` folder. Next ID is N+1. Zero-padded to 2 digits.

### 4. Create the theory folder + brief

`theories/T<NN>-<short-kebab-slug>/brief.md`. The slug is derived from the theory's mechanism — eg. `T03-process-events-race`, `T04-retention-wipe`.

Use `templates/theory-brief.md`. Required fields:

```yaml
---
id: T<NN>
status: proposed
created: <ISO datetime>
shapes: [A, B]    # which shapes this explains, [] if shapes aren't defined yet
---
```

Body sections:

- **Mechanism** — one paragraph, plain prose. What we think is happening.
- **Falsification criterion** — what specific observation would rule this out. Concrete, checkable.
- **Confirmation criterion** — what specific observation would confirm this. Concrete, checkable.
- **Cheapest evidence** — best probe type to start with (SQL / IEx / code reading / failing test / Sentry filter). One line on why.
- **Notes** — any context worth preserving for future probes.

Brief is concise — usually 30–60 lines. If it's longer, the theory is too vague or you're conflating multiple theories.

### 5. Update README

Add the theory to the projected zone's `## Theories` list, with its current status (`proposed`). Don't paste the brief in — link to the file.

### 6. Log

Append `log/YYYY-MM-DDTHH-MM-theory-proposed-T<NN>.md`:

```
# Theory proposed: T<NN>

Slug: T<NN>-<slug>
Mechanism: <one line>
File: theories/T<NN>-<slug>/brief.md
```

### 7. Commit

Commit-before-edit. After all theories from this invocation are written, commit with message `triage: hypothesise T<NN>[,T<NN>...] <slug>`.

### 8. Report

List the new theory IDs + one-line mechanism each. Suggest `probe T<id>` for whichever has the cheapest evidence path.

## Notes

A theory without a falsification criterion is not a theory. If the user proposes a free-text theory that can't be falsified ("the system is flaky"), push back and ask for a sharper statement before creating the brief.

The `shapes:` frontmatter is load-bearing for `rollup` — it powers cross-shape reasoning in the README projection. Always populate it (empty list is fine if shapes aren't defined yet).
