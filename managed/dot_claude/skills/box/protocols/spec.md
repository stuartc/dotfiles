# Protocol: spec

Compose an item's **spec** — the what, why, and the essential architectural how, with open questions allowed and visible. The spec exists to confirm the problem is understood before any agent builds on it — errors here multiply downstream. Spec writes the document and stops; planning and execution happen in their own verbs, usually in another session.

A spec is **not mandatory for every item** (per SKILL.md): write one when understanding is the risk; skip it when there's nothing to discover.

## Args

`spec <id> [<freeform steer>]`

- `<id>` — the item to spec. Must be an existing item on the track (created via `plan add`). If the id is unknown, list the track and ask — do not invent one.
- `<freeform steer>` — natural-language focus passed verbatim into the work ("the spec should nail down where bucket state lives across nodes"). Don't ignore it.

> **`spec` is also the natural home of the decomposition item.** A box's first real act is orient + decompose (see SKILL.md). The decomposition/design item is itself a spec — one whose acceptance criteria are "the work is cut into items X, Y, Z" and whose Context section is the orienting first pass. Its open questions are "what are the real seams here?", and it is ready once the other items are on the track.

## Steps

### 1. Resolve and read

Resolve the box root per SKILL.md. Confirm the item exists on the track and read whatever already stands for it:

- Its track line and state tag.
- `items/<id>/spec.md` if one already exists — `spec <id>` refines an existing spec as readily as it drafts a new one; never discard prior thinking, build on it.
- Any seed in the item's body, the box Origin, or the steer.

If `items/<id>/` doesn't exist yet, it's created on first write (step 4).

### 2. Set the item to `needs-discovery`

Speccing an item *is* the `needs-discovery` work. If the item is still `stub`, set its track tag to `` `[needs-discovery]` `` as part of this protocol (a light track edit). Re-speccing an item that's already `ready` is unusual — confirm with Stu first, since it may mean a prior plan is being reopened.

### 3. Dispatch fresh research agents per area

Discovery is agent-heavy. Break the spec's unknowns into **areas** (a subsystem, a data path, a prior-art survey) and dispatch one fresh agent per area to trace existing patterns, entry points, and prior work. Fan-out is the norm here.

Each brief follows the subagent dispatch shape in SKILL.md, plus the public-leak rule for anything touching a public surface. The artefact each agent returns is an area write-up, not an impression.

Their findings feed the spec's **Context / reading-list** and tighten the **Open Questions** — an agent's trace often answers one question and raises a sharper one.

### 4. Compose `items/<id>/spec.md`

Write (or refine) `items/<id>/spec.md` from `${CLAUDE_SKILL_DIR}/templates/spec.md`:

- **Problem / Current behaviour / Desired behaviour**, and **What / Why**.
- **The essential architectural how, bounded.** Architectural decisions the work turns on belong in the spec — for a distributed rate limiter, *where the bucket state lives across BEAM nodes* is the very thing you slowed down to decide. The boundary: architecture in the spec; implementation mechanics and code in the plan.
- **Non-goals** — what this item is explicitly *not* doing: a deliberate exclusion, not an unknown. One of the readiness-checklist ticks.
- **3–5 EARS acceptance criteria** (`WHEN <condition> THE SYSTEM SHALL <behaviour>`) — enough to prove understanding, not exhaustive; exhaustiveness is the plan's job.
- **Assumptions** — things being treated as true, kept *distinct* from Open Questions. Treating-as-true and don't-know are different failure modes; an unexamined assumption is the dangerous one.
- **Open Questions**, recorded as inline `[NEEDS CLARIFICATION]` markers — visible in place, greppable. Open questions are allowed and expected in a spec; they are not a defect to hide.
- **Context / reading-list** — the files, decisions, and prior work the research agents surfaced; doubles as the brief for any later agent.
- Optionally set `git_commit` / `branch` in the frontmatter to anchor the spec to a point in the code.

Box-native composition: no Claude Code plan mode, no `ExitPlanMode` (per SKILL.md).

### 5. Readiness

An item may only move from `needs-discovery` to `ready` when every `[NEEDS CLARIFICATION]` marker is resolved and all checklist boxes at the foot of the spec are ticked (open questions empty · non-goals stated · assumptions reviewed · ≥1 acceptance criterion). Stu ticks the checklist; that is the approval step.

`spec` itself does not set the item to `ready` and does not roll into `plan`. It composes and refines the spec, reports the remaining markers and the checklist state, and stops. Once Stu ticks the checklist, `plan <id>` writes the plan and sets the state.

### 6. Commit and log

Commit per the commit contract in SKILL.md (`box: snapshot before spec` … `box: spec <slug> <id>`). Append a `spec-written` log event naming the item, what the spec now covers, and how many `[NEEDS CLARIFICATION]` markers remain.

### 7. Offer the three doors

Per SKILL.md — never auto-execute. Here the doors are:

1. **Action it** — dispatch more research agents to close a remaining `[NEEDS CLARIFICATION]`.
2. **Write / refine** — fold an answer or decision into the spec now.
3. **Discuss** — reshape the problem framing before going further.

Wait for an explicit signal. When every marker is closed and the checklist ticked, the natural next move is `plan <id>` — surface that, but don't take it unprompted.

### 8. Report

One or two lines: which item was specced, how many `[NEEDS CLARIFICATION]` markers remain (and the headline ones), and whether the readiness checklist is clear. If it is, name the next move (`plan <id>`). Don't recap the whole spec.
