# Protocol: spec

Compose an item's **spec** — the *what, why, and load-bearing how*, with open questions allowed and visible. `spec` produces a document; it does **not** execute the work. The spec is the deliberate human slow-down: a bad line of research amplifies into thousands of bad lines of code downstream, so understanding is proven *here*, before any agent starts building. It maps to the `needs-discovery` state and writes `items/<id>/spec.md`. The plan (and `do`) come later, in their own verbs, usually in another session — respect that boundary hard.

A spec is **not mandatory for every item.** It's the artefact you write when *understanding* is the risk. A mechanical change with nothing to discover can skip straight to `plan` (`stub → ready`); a review item may be spec-heavy with a thin plan. Write a spec when there are real unknowns to resolve — don't manufacture ceremony where there isn't.

## Args

`spec <id> [<freeform steer>]`

- `<id>` — the item to spec, e.g. `spec <id>`. Must be an existing item on the track (created via `plan add`). If the id is unknown, list the track and ask — do not invent one.
- `<freeform steer>` — natural-language focus passed verbatim into the work ("the spec should nail down where bucket state lives across nodes"). Don't ignore it.

> **`spec` is also the natural home of the decomposition item.** A box's first real act is orient + decompose, not minting one big item (see SKILL.md "a box is for many items"). The decomposition/design item is itself a spec — one whose acceptance criteria are *"the work is cut into items X, Y, Z"* and whose Context section is the orienting bearings pass (the SSO box's `findings/` was an organic example of this output). Spec that item like any other: its open questions are "what are the real seams here?", and it graduates to `ready` once the other items have been projected onto the track.

## Steps

### 1. Resolve and read

Resolve the box root per the contract. Confirm the item exists on the track and read whatever already stands for it:

- Its track line and state (the `` `[state]` `` tag in the README / `plan.md` track).
- `items/<id>/spec.md` if one already exists — `spec <id>` **refines** an existing spec as readily as it drafts a new one; never blow away prior thinking, build on it.
- Any seed in the item's body, the box Origin, or the steer.

If `items/<id>/` doesn't exist yet, it's created on first write (step 4) — the item folder is the unit of work; `items/` appears on the first non-stub item.

### 2. Set the item to `needs-discovery`

Specing an item *is* the `needs-discovery` work. If the item is still `stub`, promote its track tag to `` `[needs-discovery]` `` as part of this protocol (a light track edit, no plan mode). An item already `ready` being re-spec'd is unusual — confirm with Stu before demoting, since it may mean a prior plan is being reopened.

### 3. Dispatch fresh research agents per area

Discovery is where the box earns its keep, and it's agent-heavy. Break the spec's unknowns into **areas** (a subsystem, a data path, a prior art survey, a distributed-primitive question) and dispatch **one fresh agent per area** to trace existing patterns, entry points, and prior work. Fan-out is the norm here, not the exception.

Each brief follows the contract's subagent-dispatch-shape (box root, files to read first, the named artefact to return — an area write-up, not a vibe — return format, discovery-before-commitment), plus the leak-free rule for anything touching a public surface. Never dispatch "go research X" — always with the artefact and shape.

Their findings feed the spec's **Context / reading-list** and tighten the **Open Questions** — an agent's trace often answers one question and raises a sharper one.

### 4. Compose `items/<id>/spec.md`

Write (or refine) `items/<id>/spec.md` from `${CLAUDE_SKILL_DIR}/templates/spec.md`. Fill it honestly:

- **Problem / Current behaviour / Desired behaviour**, and **What / Why**.
- **The load-bearing architectural how, bounded.** For inherently technical work, architectural decisions belong *in the spec* — designing a distributed rate limiter, *where the bucket state lives across BEAM nodes* is the very thing you're slowing down to decide, and it earns its place here. The boundary: the spec holds load-bearing **architectural** decisions; **implementation mechanics and code belong in the plan.** Don't keep the spec religiously sky-high, and don't paste code into it either.
- **Non-goals** — what this item is explicitly *not* doing. The scope fence that keeps the plan honest; distinct from Open Questions (a deliberate exclusion, not an unknown). This is one of the readiness-gate ticks, so capture it here.
- **3–5 EARS acceptance criteria** (`WHEN <condition> THE SYSTEM SHALL <behaviour>`) — enough to prove understanding, not exhaustive; exhaustiveness is the plan's job.
- **Assumptions** — things being treated as true — kept *distinct* from Open Questions. An unchallenged assumption is exactly the "bad line of research"; treating-as-true and don't-know are different failure modes and live in different sections.
- **Open Questions**, recorded as inline `[NEEDS CLARIFICATION]` markers — visible in place, greppable. **Open questions are allowed and expected** in a spec; that's the whole point of the slow-down. They are *not* a defect to hide.
- **Context / reading-list** — the files, decisions, and prior work the research agents surfaced; this section doubles as the brief for any later agent.
- Optionally set `git_commit` / `branch` in the frontmatter for provenance.

This is a composition step, **box-native**: no Claude Code native plan mode, **no `ExitPlanMode`**, no code-oriented approval gate. The spec is a document, execution is elsewhere — the code-gate would be the wrong instrument.

### 5. The readiness gate (`needs-discovery → ready`)

An item **cannot** move `needs-discovery → ready` while *any* `[NEEDS CLARIFICATION]` marker remains, or while the foot **"Ready to become a plan" checklist** is unticked (open questions empty · non-goals stated · assumptions reviewed · ≥1 acceptance criterion). Filling that checklist in **is** the human slow-down act — the concrete gesture that performs the state transition, not a vibe.

`spec` itself **does not flip the item to `ready`** and does not roll into `plan`. It composes and refines the spec, surfaces remaining `[NEEDS CLARIFICATION]` markers and the checklist state, and stops. When Stu judges the understanding sound and ticks the checklist, the item is promoted (via `plan`) and `plan <id>` authors `plan.md`. The gate is a genuine deliberation point — honour it.

### 6. Commit-before-edit, then apply

Snapshot before editing per the contract's commit-before-edit rule (`box: snapshot before spec`).

Apply the edits. Append a `spec-written` Log event (`log/YYYY-MM-DDTHH-MM-spec-written.md` from the log-entry template) — naming the item, what the spec now covers, and whether it's gated open (markers remaining) or checklist-clear. Then commit `box: spec <slug> <id>`.

### 7. Offer three doors

The spec is composed; the human decides what's next. Offer explicitly — **never auto-execute**:

1. **Action it** — dispatch more research agents to close a remaining `[NEEDS CLARIFICATION]`.
2. **Write / refine** — fold an answer or decision into the spec now.
3. **Discuss** — reshape the problem framing before going further.

Wait for an explicit signal. When every marker is closed and the checklist ticked, the natural next move is `plan <id>` (in this session or another) — surface that, but don't take it unprompted.

### 8. Report

One or two lines: which item was spec'd, how many `[NEEDS CLARIFICATION]` markers remain (and the headline ones), and whether the readiness checklist is clear. If it is, name the next move (`plan <id>`). Don't recap the whole spec.

## Notes

- **Spec proves understanding; it does not execute.** Every mode stops at the artefact — the same plan-vs-execute boundary `new` and `plan` respect. Composition is box-native: no plan mode, no `ExitPlanMode`.
- **Open questions are a feature, not a defect.** The spec exists to make unknowns *visible* via `[NEEDS CLARIFICATION]`; the item can't graduate while any remain — that constraint is the value.
- **Assumptions ≠ Open Questions.** Treating-as-true and don't-know are different failure modes; keep them in separate sections. An unexamined assumption is the dangerous one.
- **Not every item needs a spec.** Skip it when there's nothing to discover (`stub → ready` straight to `plan`). The decomposition item is a spec too — one whose acceptance is "the work is cut into items X, Y, Z".
- **Spec refines, never overwrites.** Re-running `spec <id>` builds on the existing `items/<id>/spec.md`; prior thinking is never blown away.
