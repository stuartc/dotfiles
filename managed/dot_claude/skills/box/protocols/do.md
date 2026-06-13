# Protocol: do

Execute one item. The plan says *what* (the units of work, their acceptance, their constraints); `do` decides *how* — which agents, serial or parallel, one pass or a fan-out. The plan is a brief to dispatch against, not a script to replay. There is **no fixed pipeline** here — no baked implement→review→simplify→check sequence; `do` reads the work and chooses an approach that fits this item. It runs only on an explicit go from Stu. `plan` and `spec` compose; `do` is the one verb that actually executes.

## Args

`do <id>` — the item id to execute (the `items/<id>/` folder). Required; `do` does not guess which item to run.

- `do <id>` — read the item's `spec.md` and `plan.md`, gauge the work, propose an approach, and — on an explicit go — dispatch it.
- `do <id> <freeform steer>` — fold the trailing steer in as extra context (a constraint, a phase to start from, a concern to emphasise). Pass it verbatim to whatever gets dispatched.

`do` requires a `plan.md` — `ready` means `items/<id>/plan.md` exists (a thin plan is fine). If the item is still `needs-discovery` (spec only), stop and say so: it must reach `ready` first (`box plan <id>`). If a `ready` item has no `plan.md` at all, that is an inconsistency, not a legal state — surface it and route to `box plan <id>` rather than improvising one.

## Steps

### 1. Resolve and read both artefacts

Resolve the box root per SKILL.md. Then read the item **in full**:

- `items/<id>/plan.md` — every phase: its goal, acceptance criteria (Automated/Manual), constraints, injected context excerpts, the per-phase **dependencies** and **`[P]` parallel-safe markers**, and each phase's spec back-reference (`_satisfies: …_`).
- `items/<id>/spec.md` — the what/why and the architectural decisions. Read it even though the plan is the executable artefact: the spec carries the intent and constraints the plan's phases compress. If the spec still has any `[NEEDS CLARIFICATION]` markers, the item should not have reached `ready` — stop and flag it rather than executing over an open question.

Read both fully before proposing anything. `do` is the verb where a misread costs the most.

### 2. Gauge the work

Decide the shape of the execution from what the plan tells you. Weigh:

- **Size** — one small change, or several phases.
- **File-disjointness** — phases touching the same files run serially to avoid clobbering each other; disjoint surfaces can run in parallel.
- **Risk** — high-stakes surfaces (auth, data migrations, anything irreversible) warrant a more conservative, step-by-step approach.
- **The plan's explicit dependencies + `[P]` markers** — the primary signal. Phases marked `[P]` with no unmet dependency can run in parallel; a dependency chain runs serially, with each phase's acceptance checked before the next starts.

### 3. Choose an approach

Pick the lightest approach that fits. The menu, smallest first:

- **A single agent** — one self-contained phase, or a small item.
- **An agent fan-out** — disjoint `[P]` phases dispatched in parallel, each producing its own named artefact.
- **A dynamic `Workflow`** — when the phases interlock (design in parallel → apply serially → verify) and benefit from a staged structure for this run only.
- **A per-box `workflow.js`** — when a *repeatable* harness genuinely helps this body of work. Author it on demand and store it inside the box (`<slug>/workflow.js`), never as a skill fixture. Only when the box will run the same shape again; never speculatively.

State the chosen approach and why in one or two lines before dispatching. If nothing heavier is warranted, a single agent is the right default — don't manufacture a fan-out for a one-phase item.

### 4. Dispatch using the standard shape

Every dispatched agent follows the subagent dispatch shape in SKILL.md — files to read first are the item's `plan.md` + `spec.md` plus any phase context excerpts, and the phase's acceptance criteria are the definition of done. If anything dispatched produces a public-facing artefact, pass it the public-leak rule from SKILL.md.

### 5. Run only on an explicit go

Propose the approach, then wait for Stu's explicit go. After step 3, stop and present the options:

1. **Run it** — "Go and I'll dispatch as described."
2. **Adjust the approach** — "Want it more conservative / parallelised differently / a phase dropped?"
3. **Hold** — "Just wanted to see the shape; not yet."

The trailing steer in `do <id> <steer>` is context, not consent — a steer is not a go.

### 6. Know where the output goes (box-type-dependent)

This is the rule `do` must get right, and it differs by the kind of work:

- **A review / analysis item** writes its output **into the box** — `items/<id>/findings.md`, a synthesis, and any **draft** (a review, an issue) for Stu. The thinking is the deliverable.
- **A build / code-change item** writes code to the **real repository** — on a branch in the actual project repo, not in the box. The box holds only the thinking (spec, plan, log). **Never commit a build's code into `.context/`.**

When the box type is ambiguous, ask which output location is intended before dispatching — guessing wrong is expensive in both directions.

### 7. On completion — log, report, offer next steps

When the dispatched work returns:

- **Log the outcome to `log/`, not back into `plan.md`.** `log/` plus handoff/pickup already carry execution state across sessions. Commit per the commit contract in SKILL.md (`box: snapshot before do`). Write `log/YYYY-MM-DDTHH-MM-do-ran.md` from `${CLAUDE_SKILL_DIR}/templates/log-entry.md`: the item run, the result in one line, and where the output landed (the `items/<id>/findings.md` path, or the real-repo branch name).
- **Report the diff + verification.** Show the diff (or, for a build, the branch and a diff stat) and walk each plan success criterion's status — Automated (did the tests/lint pass) and Manual (what still needs Stu's eyes). Be straight about partials: a phase that ran but didn't meet its acceptance is not done.
- **Offer next steps** (do not auto-advance):
  1. **Mark the item `done`** — via `plan` (tick the checkbox, set the tag). `do` does not relocate anything itself.
  2. **`rollup`** — regenerate the README projected zone so the track reflects the new state. (`close` later moves done bodies to `archive/`.)

Then commit `box: do <slug>/<id>`.

## Notes

- A `do` run that doesn't finish in one session ends with `handoff` (including any dead ends already ruled out); the next session `pickup`s it. Tangents surfaced mid-run go to `park`, not into the plan.
