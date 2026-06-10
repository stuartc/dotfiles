# Protocol: do

Execute one item. `do <id>` is the **harness layer**: the plan says *what* (the units of work, their acceptance, their constraints); `do` decides *how* — which agents, serial or parallel, one pass or a fan-out. The plan is not a script to replay; it is a brief to dispatch against. There is **no fixed pipeline** here — no baked implement→review→simplify→check sequence. Box work is too variable for any 1/2/3 harness to fit; `do` reads the work and chooses an approach that fits *this* item. It runs only on an explicit go from Stu, and it respects the plan-vs-execute boundary the rest of the skill guards: `plan` and `spec` compose; `do` is the one verb that actually moves.

## Args

`do <id>` — the item id to execute (the `items/<id>/` folder). The id is required; `do` does not guess which item to run.

- `do <id>` — read the item's `spec.md` and `plan.md`, gauge the work, propose an approach, and — on an explicit go — dispatch it.
- `do <id> <freeform steer>` — fold the trailing steer in as extra context (a constraint to honour, a phase to start from, a concern to emphasise). Pass it verbatim to whatever gets dispatched.

`do` requires a `plan.md` — the plan is the thing it runs against. If the item has only a `spec.md` (still `needs-discovery`), stop and say so: the item must reach `ready` first (`box plan <id>`). The exception is a thin-plan item that was promoted `stub → ready` deliberately — if a `ready` item genuinely has no plan, surface that and confirm before improvising one.

## Steps

### 1. Resolve and read both artefacts

Resolve the box root per the contract (`.context/stuart/boxes/<slug>/` relative to `pwd`, or the box the user pointed at, or the most-recently-modified box). Then read the item **in full**:

- `items/<id>/plan.md` — the agent-actionable brief. Read every phase: its goal, acceptance criteria (Automated/Manual), constraints, injected context excerpts, the per-phase **dependencies** and **`[P]` parallel-safe markers**, and each phase's spec back-reference (`_satisfies: …_`).
- `items/<id>/spec.md` — the what/why and the load-bearing architectural how. Read it even though the plan is the executable artefact: the spec carries the *intent* and the constraints the plan's phases compress. If the spec still has any `[NEEDS CLARIFICATION]` markers the item should not have reached `ready` — stop and flag it rather than executing over an open question.

Read both fully before proposing anything. `do` is the verb that amplifies — a misread here costs the most.

### 2. Gauge the work

Decide the shape of the execution from what the plan tells you. Weigh:

- **Size** — one small change, or several phases.
- **File-disjointness** — do the phases touch the same files (serialise to avoid clobber) or disjoint surfaces (safe to parallelise).
- **Risk** — high-stakes surfaces (auth, data migrations, anything irreversible) warrant a more conservative, gated approach.
- **The plan's explicit dependencies + `[P]` markers** — this is the primary signal. Phases marked `[P]` with no unmet dependency can run in parallel; a dependency chain runs serially with each phase's acceptance as a gate before the next. The plan made this explicit precisely so `do` doesn't have to infer it from order.

### 3. Choose an approach (resourceful, never a fixed harness)

Pick the lightest approach that fits. The menu, smallest first:

- **A single agent** — one self-contained phase, or a small item.
- **An agent fan-out** — disjoint `[P]` phases dispatched in parallel, each producing its own named artefact.
- **A dynamic `Workflow`** — when the phases interlock (design-in-parallel → apply-serially → verify) and benefit from a staged structure for *this run only*.
- **A per-box `workflow.js`** — when a *repeatable* harness genuinely helps this body of work (the pr-4751 pattern). Author it on demand and store it **inside the box** (`<slug>/workflow.js`), never as a skill fixture. Only reach for this when the box will run the same shape again; do not author one speculatively.

State the chosen approach and why in one or two lines before dispatching. If none of the heavier options is warranted, a single agent is the honest default — don't manufacture a fan-out for a one-phase item.

### 4. Dispatch using the standard shape

Every dispatched agent follows the **subagent dispatch shape** from the skill contract: (1) the box root path, (2) the specific files to read first (the item's `plan.md` + `spec.md`, plus any phase context excerpts), (3) the named artefact path it must produce, (4) the ≤5-line return format, (5) the discovery-before-commitment rule (≤5 tool calls to confirm the data shape before committing to long work). Never dispatch "go implement the plan" — always with the phase's acceptance criteria as the definition of done and the artefact path it writes.

If anything dispatched produces a **public-facing** artefact (a PR description, a GitHub issue, an external comment), pass it the **leak-free rule**: it must stand alone in plain English, carry none of the box's internal vocabulary (no `F<id>`, no slug, no `plan.md`/`follow-ups/` pointers), and per Stu's standing rule it is **draft only — never posted**.

### 5. Run only on an explicit go

`do` proposes; Stu disposes. After step 3, stop and present the approach as a door:

1. **Run it** — "Go and I'll dispatch as described."
2. **Adjust the approach** — "Want it more conservative / parallelised differently / a phase dropped?"
3. **Hold** — "Just wanted to see the shape; not yet."

Wait for an explicit go before dispatching. The trailing steer in `do <id> <steer>` is context, not consent — a steer is not a go.

### 6. Know where the output goes (box-type-dependent)

This is the rule `do` must get right, and it differs by the kind of work:

- **A review / analysis item** writes its output **into the box** — `items/<id>/findings.md`, a synthesis, and any **draft** (a review, an issue) for Stu. The thinking *is* the deliverable; it belongs in the box.
- **A build / code-change item** writes code to the **real repository** — on a branch in the actual project repo (e.g. Lightning), not in the box. The box holds only the *thinking* (the spec, the plan, the log of what happened). **Never commit a build's code into `.context/`** — the box is a working tool, not where the product lives.

When the box type is ambiguous, ask which output location is intended before dispatching — guessing wrong here is expensive (a build's diff committed into the context repo, or review findings stranded outside the box).

### 7. On completion — log, report, offer the doors

When the dispatched work returns:

- **Log the outcome to `log/`, not back into `plan.md`.** Box already carries execution state across sessions via `log/` + `handoff`/`pickup`; do not duplicate it into the plan file. Commit-before-edit applies — snapshot first (`box: snapshot before do`, skipped silently on a clean tree; stop and ask on **unrelated** changes), resolve `CONTEXT_REPO=$(readlink -f .context)`, run git with `git -C "$CONTEXT_REPO" …`, never `cd` into the target. Write `log/YYYY-MM-DDTHH-MM-do-ran.md` from `${CLAUDE_SKILL_DIR}/templates/log-entry.md`, mapping `{{EVENT_TYPE}}` → `do-ran`; `{{ISO_DATETIME}}` → now; `{{ARTEFACT_POINTER}}` → where the output landed (the `items/<id>/findings.md` path, or the real-repo branch name); `{{WHAT_CHANGED}}` and `{{ONE_LINE_CONTEXT}}` → one line naming the item run and the result.
- **Report the diff + verification.** Show the diff (or, for a build, the branch and a `git -C <repo> diff --stat`-style summary) and walk **each plan success-criterion's status** — Automated (did the tests/lint/dialyzer pass) and Manual (what still needs Stu's eyes). Be honest about partials: a phase that ran but didn't meet its acceptance is not done.
- **Offer the closing doors** (do not auto-advance):
  1. **Mark the item `done`** — flip the item's state tag to `` `[done]` `` via `plan` (tick the checkbox and set the tag). `do` does not relocate anything itself.
  2. **Demote to `archive/`** — once `done`, the item's bodies can move to `archive/` per the archival rule (`rollup`/`close` own the demotion machinery; `do` offers it, doesn't reinvent it).
  3. **`rollup`** — regenerate the README projected zone so the track reflects the new state.

Then commit: `git -C "$CONTEXT_REPO" add -A` and `git -C "$CONTEXT_REPO" commit -m "box: do <slug>/<id>"`. No co-author lines, no skip-hooks. If `.context/` isn't a git repo, skip the commit and tell the user.

## Notes

- **`do` is the harness, the plan is the brief.** The plan names *what* and its acceptance; `do` decides *how* to dispatch it. This is the "Code as Agent Harness" split (`[[box-skill-v1.3-context]]` §5): a plan that prescribes the *how* ages badly; `do` is where the *how* lives, freshly chosen per run.
- **No fixed pipeline.** There is deliberately no implement→review→simplify→check sequence baked in. `do` gauges the work and picks an approach; a heavier harness (`workflow.js`) is authored only when a *repeatable* shape genuinely warrants it, and it lives in the box, never in the skill.
- **Output location is box-type-dependent and load-bearing.** Reviews write findings + a draft *into* the box; builds write code to the *real repo* and leave only thinking in the box. A build's code never lands in `.context/`.
- **`do` runs only on an explicit go.** It is the one verb that moves; every composing verb (`spec`, `plan`) stops at the artefact. The proposal-then-go gate keeps the plan-vs-execute boundary intact.
- **Execution state goes to `log/`, never back into `plan.md`.** The plan stays a clean brief; the log is the append-only record of what running it produced.
- **Spans sessions cleanly.** A `do` run that doesn't finish in one session ends with `handoff` (carry-forward, including any dead-ends already ruled out); the next session `pickup`s it. Tangents surfaced mid-run go to `park`, not into the plan.
