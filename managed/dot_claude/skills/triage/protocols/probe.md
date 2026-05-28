# Protocol: probe

Write a probe to test a theory. Discovery first, then probe. Hand back to user to run if execution requires their access.

## Args

`probe T<id> [extra steer]` — required: the theory ID. Extra text after gets passed to the dispatched agent as additional context.

## Steps

### 1. Resolve and read

Find the investigation root. Confirm `theories/T<id>-*/brief.md` exists. Read it. Read README's `## Probes` listing to know the next probe number.

If the theory's status is already `falsified` or `confirmed`, ask the user whether they want to re-probe (eg. with stronger evidence) before proceeding.

### 2. Pick the probe number

Highest existing `probes/NN.<ext>` + 1, zero-padded to 2 digits.

### 3. Dispatch the probe-writing subagent

Use `Agent` with `general-purpose` (or domain-specific if available — eg. `phoenix-elixir-expert` for Elixir investigations). Brief:

> Write a probe for theory T<id> in `<investigation root>/`.
>
> Read `theories/T<id>-<slug>/brief.md`. Pay attention to the falsification criterion — that's what your probe is testing.
>
> **Discovery first (≤5 tool calls).** Before writing the probe, verify the data you'd need exists in the shape you assume. Examples:
> - For a SQL probe: confirm the relevant table and columns exist by running `\d <table>` or a `SELECT … LIMIT 1`
> - For an IEx probe: confirm the module / function is loaded by running a tiny `Code.ensure_loaded?/1` or `apply/3`
> - For a Sentry filter: run a list call with `limit: 5` and verify the fields you'd filter on are present in the list response (not just per-event detail)
> - For a code-reading probe: confirm the entry point exists by `Grep`
>
> If discovery shows the data isn't there in the assumed shape, **stop and report back** — don't fabricate a probe. The main session can replan.
>
> If discovery passes, write the probe to `<root>/probes/<NN>.<ext>`. Extensions:
> - `.sql` for PostgreSQL probes
> - `.iex` (or `.exs`) for IEx / Elixir probes
> - `.sh` for shell probes
> - `.md` for code-reading writeups (the "probe" is the analysis; output is inline)
>
> Every probe starts with a boxed header in the language's comment syntax:
>
> ```
> -- ------------------------------------------------------------------
> -- Purpose:        what we're testing
> -- Theory:         T<id> (or T<id>,T<id> if it falsifies multiple)
> -- Side effects:   none | reads-only | mutates (describe)
> -- How to run:     ./scripts/run-sql.sh probes/NN.sql > probes/NN.out
> -- Expected:       what a falsification / confirmation looks like
> -- ------------------------------------------------------------------
> ```
>
> If the probe **mutates** anything (cursor advance, retry, write), add a `WARNING: MUTATING` line and double-check it can't run accidentally as part of a diagnostic batch.
>
> **If you can run it yourself** — eg. local DB via Tidewave MCP, dev IEx, a local grep — do so and write the output to `<root>/probes/<NN>.out`. Then proceed to step 4 below.
>
> **If you can't run it** — eg. prod access required, kubectl exec needed — write only the probe file. Return the exact runner command the user should execute. Do not try to run it yourself.
>
> If a discovery probe was needed and produced output, save it as `<root>/probes/<NN>-discovery.<ext>` + `.out`. Reference it from the main probe's header comments.
>
> Failing-test mode: if the cheapest evidence is a failing test in the project's actual test suite:
> - Write the test in the project's normal test tree (eg. `apps/lightning/test/lightning/run_test.exs`)
> - Tag it `@tag :reproduces_bug` (or the project's convention) so CI stays green
> - Run it (`mix test --only reproduces_bug` or equivalent) to confirm it fails
> - Capture the test command + failure output as `<root>/probes/<NN>-test-output.txt`
> - The "probe file" `<root>/probes/<NN>.md` is a short pointer note: test path, tag, command, link to the .txt output
>
> Return ≤5 lines:
> - Probe path
> - Discovery result (`passed` / `re-planned` / `not needed`)
> - Whether you ran it or are handing back
> - If handing back, the exact command
> - If you ran it, a one-line summary of the result (don't pre-interpret — that's `findings`' job)

Append user's extra steer to the brief.

### 4. Handle the return

**Agent ran it directly:** the `.out` file exists. Proceed to suggest `findings T<id>` next.

**Agent handed back:** tell the user the runner command exactly as the agent returned it. Stop. Stu runs the probe externally, saves the output, then fires `findings T<id>` himself.

**Discovery failed:** report what didn't exist as assumed. Ask the user how to replan — sometimes the theory's brief needs revising before any probe is sensible.

### 5. Log

Append `log/YYYY-MM-DDTHH-MM-probe-run-NN.md`:

```
# Probe NN: T<id>

File: probes/NN.<ext>
Discovery: <passed | re-planned | not-needed>
Execution: <ran-by-agent | handed-back | failed>
Theories tested: T<id>[, T<id>]
```

### 6. Commit

`triage: probe NN for T<id>`.

### 7. README update

The README's `## Probes` section lists probes by number with one-line purpose and pointer to the file. Update it. Don't list `.out` files separately — they're paired.

## Strict scope

The probe protocol does not interpret results. Even if the agent ran the probe and the output is screaming "this is the bug", it returns one line of summary and stops. The verdict — falsified / confirmed / inconclusive — happens in `findings`. This separation prevents probe writers from confirmation-biased interpretation and keeps the artefacts atomic.
