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

Resolve the box root per the contract (`.context/stuart/boxes/<slug>/`, or the box the user pointed at, or the most-recently-modified box). Confirm the item exists on the track and read whatever already stands for it:

- Its track line and state (the `` `[state]` `` tag in the README / `plan.md` track).
- `items/<id>/spec.md` if one already exists — `spec <id>` **refines** an existing spec as readily as it drafts a new one; never blow away prior thinking, build on it.
- Any seed in the item's body, the box Origin, or the steer.

If `items/<id>/` doesn't exist yet, it's created on first write (step 4) — the item folder is the unit of work; `items/` appears on the first non-stub item.

### 2. Set the item to `needs-discovery`

Specing an item *is* the `needs-discovery` work. If the item is still `stub`, promote its track tag to `` `[needs-discovery]` `` as part of this protocol (a light track edit, no plan mode). An item already `ready` being re-spec'd is unusual — confirm with Stu before demoting, since it may mean a prior plan is being reopened.

### 3. Dispatch fresh research agents per area

Discovery is where the box earns its keep, and it's agent-heavy. Break the spec's unknowns into **areas** (a subsystem, a data path, a prior art survey, a distributed-primitive question) and dispatch **one fresh agent per area** to trace existing patterns, entry points, and prior work. Fan-out is the norm here, not the exception.

Restate the dispatch rules **directly** — this protocol does not run inside any plan mode and cannot rely on inheriting them. Every brief includes, per the contract's subagent-dispatch-shape: (1) the box root path, (2) the specific files to read first, (3) the named artefact the agent must return (an area write-up, not a vibe), (4) the ≤5-line return format, (5) the discovery-before-commitment rule (≤5 calls to confirm the data shape before committing to a long trace). Anything that touches a public surface also carries the leak-free rule. Never dispatch "go research X" — always with the artefact and shape.

Their findings feed the spec's **Context / reading-list** and tighten the **Open Questions** — an agent's trace often answers one question and raises a sharper one.

### 4. Compose `items/<id>/spec.md`

Write (or refine) `items/<id>/spec.md` from `${CLAUDE_SKILL_DIR}/templates/spec.md`. Fill it honestly:

- **Problem / Current behaviour / Desired behaviour**, and **What / Why**.
- **The load-bearing architectural how, bounded.** For inherently technical work, architectural decisions belong *in the spec* — designing a distributed rate limiter, *where the bucket state lives across BEAM nodes* is the very thing you're slowing down to decide, and it earns its place here. The boundary: the spec holds load-bearing **architectural** decisions; **implementation mechanics and code belong in the plan.** Don't keep the spec religiously sky-high, and don't paste code into it either.
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

Per the contract: before editing, stage and commit the current state — `box: snapshot before spec`. Resolve the repo root once with `CONTEXT_REPO=$(readlink -f .context)` (use `greadlink -f` if unavailable) and run git with `-C` — do **not** `cd` into the target. Snapshot with `git -C "$CONTEXT_REPO" commit -m "box: snapshot before spec"` (skip silently if the tree is clean; **stop and ask** if there are unrelated changes rather than sweeping them in).

Apply the edits. Append a `spec-written` Log event (`log/YYYY-MM-DDTHH-MM-spec-written.md` from the log-entry template) — naming the item, what the spec now covers, and whether it's gated open (markers remaining) or checklist-clear. Then `git -C "$CONTEXT_REPO" add -A` and `git -C "$CONTEXT_REPO" commit -m "box: spec <slug> <id>"`.

### 7. Offer three doors

The spec is composed; the human decides what's next. Offer explicitly — **never auto-execute**:

1. **Action it** — dispatch more research agents to close a remaining `[NEEDS CLARIFICATION]`.
2. **Write / refine** — fold an answer or decision into the spec now.
3. **Discuss** — reshape the problem framing before going further.

Wait for an explicit signal. When every marker is closed and the checklist ticked, the natural next move is `plan <id>` (in this session or another) — surface that, but don't take it unprompted.

### 8. Report

One or two lines: which item was spec'd, how many `[NEEDS CLARIFICATION]` markers remain (and the headline ones), and whether the readiness checklist is clear. If it is, name the next move (`plan <id>`). Don't recap the whole spec.

## Notes

- **Spec proves understanding; it does not execute.** Every mode stops at the artefact. The same plan-vs-execute boundary `new` and `plan` respect.
- **Open questions are a feature, not a defect.** The spec exists to make unknowns *visible* via `[NEEDS CLARIFICATION]`. The item can't graduate while any remain — that constraint is the value.
- **Assumptions ≠ Open Questions.** Treating-as-true and don't-know are different failure modes; keep them in separate sections. An unexamined assumption is the dangerous one.
- **"Some how" is allowed, bounded.** Load-bearing architectural decisions belong in the spec; implementation mechanics and code belong in the plan. Don't keep specs religiously sky-high; don't paste code into them.
- **No plan mode, no `ExitPlanMode`.** Spec composition is box-native. The code-oriented gate is the wrong instrument for a document whose execution happens elsewhere.
- **Not every item needs a spec.** Skip it when there's nothing to discover (`stub → ready` straight to `plan`). The spec is the thing you write when understanding is the risk; forcing it on every item re-introduces the ceremony the box exists to avoid.
- **The decomposition item is a spec too.** A box's opening orient + decompose work is itself a spec whose acceptance is "the work is cut into items X, Y, Z". Don't be eager to mint one all-encompassing item — the items, plural, are the work.
- **Spec refines, never overwrites.** Re-running `spec <id>` builds on the existing `items/<id>/spec.md`; prior thinking is never blown away.

## Discovery rule

When dispatching research agents, **do not paginate** through whole histories, codebase-wide greps, or large fan-outs blind. Each agent spends ≤5 tool calls confirming the data shape exists before committing to the trace, then writes its named area artefact. This is the stuck-agent insurance — confirm the shape, then commit.
