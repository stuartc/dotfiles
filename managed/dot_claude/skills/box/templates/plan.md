---
item: {{ID}}
state: ready
---

# Plan — {{ID}}: {{TITLE}}

_**Agent-actionable.** Where the spec proves understanding, the plan is **distinctly executable by an agent**: PRD-like, phased, much closer to real code than the spec, and with **zero open questions** by the time it's final. The plan is the thing `box do {{ID}}` runs against._

_Phrase phases as **WHAT, not HOW**: name the unit of work, its acceptance, its constraints, and the context a fresh agent needs — **not** a script of tool calls or a fixed agent assignment. `do` is the harness layer: it reads the plan and decides **how** to dispatch (single agent, fan-out, dynamic workflow, or a per-box `workflow.js`). The plan names phases as units of work; it does **not** script their execution and never invokes plan mode._

## Overview

{{OVERVIEW}}

## Current State

{{CURRENT_STATE}}

_What exists now, what's missing, the constraints discovered. Cite specifics (`path:line`) so a fresh agent doesn't re-derive them._

## Desired End State

{{DESIRED_END_STATE}}

**Verify by:** {{HOW_TO_VERIFY}}

## What We're NOT Doing

_Explicit out-of-scope, to stop scope creep._

- {{NON_GOAL}}

## Phases

_Each phase is a **unit of work**, not a command script. A fresh agent could be handed any one phase with the context below and nothing else._

### Phase 1 — {{PHASE_NAME}}  [P]

- **Goal (WHAT):** {{WHAT_THIS_PHASE_ACHIEVES}}
- **Depends on:** {{NONE_OR_PHASE_REFS}}
- _`[P]` marks a phase as **parallel-safe** — no dependency on an unfinished sibling. `do` reads `Depends on:` + `[P]` to choose serial vs parallel dispatch. Drop the `[P]` tag from phases that must wait._
- **Constraints:** {{CONSTRAINTS}}
- **Context excerpts:** {{INJECTED_CONTEXT}}
  - _Pre-populate the starting state a fresh agent needs so it doesn't re-read a prior phase's output to learn where it begins._
- _satisfies: {{SPEC_ACCEPTANCE_CRITERION}}_

#### Success criteria

**Automated:**
- [ ] {{AUTOMATED_CHECK_E_G_TEST_OR_LINT_COMMAND}}

**Manual:**
- [ ] {{MANUAL_CHECK}}

<!-- OPTIONAL — only for genuinely risky phases. Delete if not needed; do not leave empty.
**Hypothesis / pivot:** {{WHAT_WE_EXPECT}} — if {{SIGNAL}}, pivot to {{ALTERNATIVE}}.
-->

---

### Phase 2 — {{PHASE_NAME}}

- **Goal (WHAT):** {{WHAT_THIS_PHASE_ACHIEVES}}
- **Depends on:** Phase 1
- **Constraints:** {{CONSTRAINTS}}
- **Context excerpts:** {{INJECTED_CONTEXT}}
- _satisfies: {{SPEC_ACCEPTANCE_CRITERION}}_

#### Success criteria

**Automated:**
- [ ] {{AUTOMATED_CHECK}}

**Manual:**
- [ ] {{MANUAL_CHECK}}

---

## References

- Spec: `items/{{ID}}/spec.md`
- {{OTHER_REFERENCES}}

---

_**No open questions.** Every decision is made before this plan is final — if a question is still open, it belongs in the spec, and this item is not yet `ready`. `do` will not run a plan that still reasons out loud._
