# Protocol: fix-spec

Draft a concrete fix for a confirmed (or partially-confirmed) theory.

## Args

`fix-spec [T<id>] [extra steer]` — optional theory ID. If omitted, look at all confirmed/partially-confirmed theories and ask the user which to spec for. Extra steer passed to the dispatched agent.

## Steps

### 1. Resolve and read

Find the investigation root. Read every confirmed or partially-confirmed theory's brief + findings. Read the README to understand the broader picture.

If multiple theories are confirmed and the user didn't specify, ask which one (or all in scope) to spec for. Multiple confirmed theories may share a fix or be distinct — let the user decide.

### 2. Dispatch the fix-spec subagent

Brief:

> Draft a fix spec for theory T<id> in `<investigation root>/`.
>
> Read:
> - `theories/T<id>-<slug>/brief.md` and `findings.md`
> - Any related theories the findings references
> - The relevant code paths (the findings should cite them — follow the pointers)
>
> Produce `<investigation root>/fix-spec.md` (or append a section if it already exists) with:
>
> - **Target** — which theory / shape this fix addresses
> - **Diagnosis recap** — 2–3 sentences, link to findings rather than duplicating
> - **Fix description** — what changes, where (file paths + line refs), why
> - **Test strategy** — what test demonstrates the fix works. If a `:reproduces_bug` test already exists from a probe, point at it — the fix should make it pass (un-tag once green).
> - **Risk assessment** — what could go wrong with this fix. Specifically: regression surface, performance impact, rollout considerations.
> - **Out of scope** — what this fix deliberately doesn't address (eg. related theories, broader refactor opportunities). Stops scope creep.
> - **Open questions** — anything the user needs to decide before implementing
>
> Do not write any code. The spec describes the change; implementation is a separate step (usually a `slice` or direct edit by the user). Stay focused on what would prove the fix correct.
>
> Return ≤5 lines:
> - Headline change (one line)
> - Test strategy (one line)
> - Open questions count (n)
> - Path to fix-spec.md

Append user's extra steer.

### 3. README update

Add a `## Fix spec` line in the projected zone, linking to `fix-spec.md`. If the spec covers multiple theories, note that.

### 4. Log

Append `log/YYYY-MM-DDTHH-MM-fix-spec-drafted.md`:

```
# Fix spec drafted

Theories: T<id>[, T<id>]
Headline: <one line>
File: fix-spec.md
Open questions: <n>
```

### 5. Commit

`triage: fix-spec for T<id>[, T<id>]`.

### 6. Report

Headline + test strategy + open questions count. Suggest next step:

- If open questions exist → answer them, possibly with another probe
- If clean → either implement directly, or invoke `slice` to break the fix into shippable pieces

## Notes

The fix spec is the natural handoff point to other workflows (`slice` for breaking into PRs, `implement-plan` for direct execution). The investigation isn't "closed" by writing a fix spec — it stays open until the fix lands and the bug stops happening. Add a closure event later (`triage: close <slug>` is not a subcommand — just commit a final note to the log when you're confident).
