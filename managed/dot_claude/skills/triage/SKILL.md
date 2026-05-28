---
name: triage
description: Multi-session bug triage with named artefacts, theory lifecycle, and append-only history. Use for production bug investigations that span multiple sessions and need to stay legible as they grow.
argument-hint: "<subcommand> [args] — eg. init <slug>, probe T02, findings T02, rollup, status"
---

# Triage

Investigations grow. README files balloon to 800 lines, theories get overwritten silently, fresh sessions lose context. This skill imposes a thin structure that survives multi-session work without becoming the bag-of-everything.

The core idea: the main session is a **dispatcher with a typed vocabulary**. Each subcommand produces a named artefact in a predictable place. History is append-only. The README is a thin index, not the substance.

## When to use

- A production bug that needs more than one session to understand
- Multiple competing theories, multiple shapes of evidence
- You want to be able to start a fresh session without re-reading 4,000 lines

## When NOT to use

- A bug you can fix in one session — just fix it
- A feature spec or implementation plan — use `slice` / `bd`
- A meeting note or write-up — use the workbook

## Investigation folder layout

Default location: `.context/stuart/investigations/<slug>/` in the current project. The skill assumes `.context/` is a symlink (or real folder) inside the project. If `.context/` doesn't exist, **ask** before scaffolding elsewhere.

```
<slug>/
├── README.md                # thin index: static top + projected current state
├── references.md            # Sentry / GitHub / PR refs pulled at intake (if any)
├── log/                     # append-only event files, timestamped
│   └── 2026-05-26T11-10-intake.md
├── theories/                # one subfolder per probed theory
│   └── T02-process-events/
│       ├── brief.md         # falsification criterion, written at hypothesise
│       └── findings.md      # verdict + evidence pointers, written after probe
├── probes/                  # flat, numbered, shared across theories
│   ├── 01.sql / 01.out
│   ├── 02.iex / 02.out
│   └── 03-discovery.sql / 03-discovery.out
├── scripts/                 # runners (run-sql.sh, run-iex.sh) — scaffolded at init
├── scope.md                 # optional, from /triage scope
├── shapes.md                # optional, from /triage taxonomy
├── followups.md             # optional, spinoff candidates from /triage followup
└── fix-spec.md              # once a theory is confirmed
```

## Subcommand vocabulary

| Subcommand | Purpose | Produces | Protocol |
|---|---|---|---|
| `init <slug> [--sentry|--gh|--pr REF]` | Scaffold the folder | folder tree + README + references.md | `protocols/init.md` |
| `scope` | How prevalent / who's affected | `scope.md` | `protocols/scope.md` |
| `taxonomy` | Categorise error shapes (A/B/C/X) | `shapes.md` | `protocols/taxonomy.md` |
| `hypothesise [text]` | Propose theories | `theories/T<id>/brief.md` per theory | `protocols/hypothesise.md` |
| `probe T<id>` | Write probe + discovery, hand back runner | `probes/NN.*` | `protocols/probe.md` |
| `findings T<id>` | Interpret probe output, write verdict | `theories/T<id>/findings.md` | `protocols/findings.md` |
| `followup [text]` | Park a spinoff discovery that's out of scope for this investigation | `followups.md` entry `F<id>` | `protocols/followup.md` |
| `fix-spec [T<id>]` | Draft fix for a confirmed theory | `fix-spec.md` | `protocols/fix-spec.md` |
| `rollup` | Regenerate README projected zone from log + theories | updated README | `protocols/rollup.md` |
| `status` | Print current state, no edits | conversation only | `protocols/status.md` |

## Routing

Parse the first token of the argument as the subcommand. Anything after the subcommand args is optional steer — pass it to the dispatched agent as extra context, don't ignore it.

For each subcommand, **read the corresponding `protocols/<name>.md` file in this skill folder** and follow it. The protocol files contain the agent dispatch templates and step-by-step rules. Don't try to remember them from this index.

If the subcommand is unrecognised, list the vocabulary back to the user and ask.

## Conventions across all subcommands

**Investigation root.** Resolve once per invocation: `pwd`-relative `.context/stuart/investigations/<slug>/`. If no slug context exists yet (first call wasn't `init`), check for the most recently-modified investigation folder or ask.

**Theory IDs.** `T01`, `T02`, … — assigned by `hypothesise`, never reused, never renumbered. Falsified theories keep their ID and folder forever.

**Follow-up IDs.** `F1`, `F2`, … — assigned by `followup`, never reused, never renumbered. A follow-up is a spinoff *discovery* that's out of scope for the current investigation but mustn't be lost: it becomes its own `/triage init` or a GitHub issue later. Distinct from a theory (a theory is a candidate explanation of *this* bug; a follow-up is a *different* problem noticed in passing). Entries live in `followups.md`, each carrying enough context to spin out without re-discovery.

**Probe numbering.** Flat, sequential across the investigation. Next free integer. Zero-padded to 2 digits (`01`, `02`, … `99`). Discovery probes use a suffix: `03-discovery.sql`.

**Probe pairing.** Every probe is a pair: `NN.<ext>` for the script, `NN.out` for the output. If the agent runs it directly, write both. If you hand back to Stu to run, write the script + the runner command; the `.out` arrives later via `findings`.

**Boxed probe headers.** Every probe script starts with a header block:

```
# --------------------------------------------------------------------
# Purpose:        what we're testing
# Theory:         T<id> (or T<id>,T<id> if it falsifies multiple)
# Side effects:   none | reads-only | mutates (describe)
# How to run:     ./scripts/run-sql.sh probes/NN.sql > probes/NN.out
# Expected:       what a falsification / confirmation looks like
# --------------------------------------------------------------------
```

Use the comment syntax of the probe language (`--` for SQL, `#` for shell, `#` for Elixir/IEx).

**Named shapes early.** Once `taxonomy` defines shape names (A/B/C/X or whatever), every subsequent artefact uses those names verbatim. The skill maintains the canonical list in `shapes.md`.

**Event log.** Append-only, never edited. One file per major transition, named `YYYY-MM-DDTHH-MM-<event-type>.md`. Event types worth logging:

- `intake` — folder created
- `scope-recorded`
- `taxonomy-recorded`
- `theory-proposed:T<id>`
- `probe-run:NN` — includes outcome (ran / handed-back / failed)
- `theory-falsified:T<id>` / `theory-confirmed:T<id>` / `probe-inconclusive:T<id>`
- `theory-superseded:T<id>-by-T<id>`
- `shape-discovered:<name>`
- `followup-parked:F<id>` — one event per follow-up parked (or one covering several if parked together)
- `fix-spec-drafted`
- `session-handoff` / `session-pickup`

Each event file is short — usually 5–20 lines: timestamp, what changed, pointer to the artefact, one line of context. Don't log every edit. Only log when state Stu cares about has shifted.

**Commit-before-edit.** Before any edit that modifies README, theory briefs/findings, scope, shapes, or fix-spec, the skill stages the current state and commits it with a message like `triage: snapshot before <subcommand>`. This addresses the "I forget to commit and then can't recover" pain. Use a generic commit, no co-author lines, no skip-hooks. If the working tree has unrelated changes, **stop and ask** rather than sweeping them in.

**Discovery before commitment.** Any subagent that's about to run something potentially long (Sentry pagination, big SQL, codebase-wide grep, large agent dispatch) **must** spend ≤5 tool calls verifying the data shape exists before committing to the work. This is the 10-hour-stuck-agent insurance and applies to every probe protocol.

**Subagent dispatch shape.** When a protocol dispatches a subagent, the brief always includes: (1) the investigation root path, (2) which specific files the subagent should read first, (3) the named artefact path it must produce, (4) ≤5-line return format expected, (5) the discovery-before-commitment rule. Never dispatch with "go investigate X" — always with the artefact path and shape.

## Pickup ergonomics

When a fresh session starts mid-investigation, the user can run `/triage status` to get current state without re-reading anything. The `status` protocol prints: open theories, last 5 log events, where the README projected section is, and a "point me at" prompt asking which task they want to fire next.

`/handoff` and `/pickup` still work alongside — handoffs go to the OS temp dir per their convention, not into the investigation folder. Reference investigation paths from handoffs.

## Style

- British English in scaffolded files
- No emoji
- Short, opinionated, complete sentences
- File templates use Markdown; YAML frontmatter only on `theories/*/brief.md` (status field is load-bearing for `rollup`)
- No back-references in artefacts ("as discussed earlier") — every artefact stands alone or links explicitly

## Out of scope

- Cross-investigation knowledge (no shared theory library)
- Auto-prevalence checks (you run `scope` yourself when you want it)
- CI integration / automated probe runs
- Multi-user collaboration
