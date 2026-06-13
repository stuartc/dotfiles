---
item: {{ID}}
state: needs-discovery
# Optional — fill when the spec is anchored to a point in the code.
# git_commit: {{COMMIT}}
# branch: {{BRANCH}}
---

# Spec — {{ID}}: {{TITLE}}

_The **what and why**, plus the essential architectural how. The spec exists to confirm the problem is understood before any agent builds on it — errors here multiply downstream. Open questions are **allowed and visible here** — that is the point of a spec. Write `plan.md` only once the "Ready to become a plan" checklist at the foot is fully ticked._

_Not every item needs a spec. Skip it (set `stub → ready`) when there is nothing to discover. Write one when **understanding is the risk** — a review, a new subsystem, an architectural decision. A spec is also the natural vehicle for the box's **decomposition item**: a spec whose acceptance is "the work is cut into items X, Y, Z."_

## Overview

{{OVERVIEW}}

_One or two paragraphs: what this item is about and why it matters. Enough for a fresh session to know if this is the item it wants._

## Problem / Current behaviour / Desired behaviour

- **Problem:** {{PROBLEM}}
- **Current behaviour:** {{CURRENT}}
- **Desired behaviour:** {{DESIRED}}

_The triple that frames the gap. For a decomposition item, "desired behaviour" is "the work is understood and cut into addressable items."_

## What & why — and the essential how

{{WHAT_WHY}}

_What we're taking on and why it's worth doing. Include the **architectural decisions the work turns on** (e.g. "where bucket state lives across BEAM nodes"). Architecture belongs here; **implementation code does not** — that's the plan's job. Don't keep the spec artificially high-level for inherently technical work, but don't paste code into it either._

## Non-goals

_What this item is explicitly **not** doing — the scope fence that keeps the plan tight. Distinct from Open Questions: a non-goal is a deliberate exclusion, not an unknown._

- {{NON_GOAL}}

## Acceptance criteria

_3–5 criteria, EARS format — enough to **prove understanding**, not to be exhaustive (exhaustiveness is the plan's job)._

1. WHEN {{CONDITION}} THE SYSTEM SHALL {{BEHAVIOUR}}
2. WHEN {{CONDITION}} THE SYSTEM SHALL {{BEHAVIOUR}}
3. WHEN {{CONDITION}} THE SYSTEM SHALL {{BEHAVIOUR}}

## Assumptions

_Things we are **treating as true** without having confirmed them. Distinct from Open Questions: an assumption is a belief we're running on; an open question is a known gap. An unchallenged assumption is exactly the kind of early error that multiplies downstream — review these deliberately._

- {{ASSUMPTION}}

## Open Questions

_Known gaps. Mark each in place with `[NEEDS CLARIFICATION: <the question>]`. These are **allowed and expected** in a spec. The item may not move to `ready` while any remain._

- [NEEDS CLARIFICATION: {{QUESTION}}]

## Context / reading-list

_Files, prior work, decisions, and links a fresh session (or a research agent) needs to orient. This section **doubles as the brief** for any research agents `spec` dispatches — point them here._

- {{PATH_OR_LINK}} — {{WHY_IT_MATTERS}}

---

## Ready to become a plan

_An item may only move from `needs-discovery` to `ready` when every `[NEEDS CLARIFICATION]` marker is resolved and all the boxes below are ticked. Stu ticks the checklist; that is the approval step. All boxes ticked ⇒ the spec is done and `plan {{ID}}` can begin._

- [ ] No `[NEEDS CLARIFICATION]` markers remain
- [ ] Non-goals stated (what this item is explicitly **not** doing)
- [ ] Assumptions reviewed
- [ ] At least one acceptance criterion
