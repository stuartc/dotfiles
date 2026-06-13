# Box skill

A file-first work-driver for a single multi-day or multi-week body of work. A box is an on-disk folder holding the durable state for one body of work — the plan, the parked follow-ups, the history, and an always-current head — so a fresh session opens the box and can continue without reconstructing context by hand. It starts as a single README and grows folders only as needed; the layout never changes shape.

`SKILL.md` is the operational spec Claude reads. This README is for Stu.

## Why this exists

Validated against the real `Lightning.Adaptors` rewrite: a 7-week, 5-burst project, ~13k lines of artefacts across ~45 docs. Two research passes — a structural read of the artefacts folder and a fan-out over the interactive sessions reading the verbatim prompts — surfaced the findings that shaped the design:

- **The head-of-box is the highest-value artefact, and it was missing for six weeks.** The `00-SESSION-BOOTSTRAP.md` was hand-built only near the end. "I don't want to surgically recreate good context every session." So the skill owns keeping the head fresh — it doesn't rely on discipline.
- **Park is used at session boundaries, not mid-flow.** The dominant real behaviour is *commit what we have, then write a prompt to resume in another session*. So `park` pairs follow-up capture with a carry-forward handoff.
- **Stu's language assigns a fate, not a deferral.** "bin it", "leave it dead until phase c". Every park records a decision about where the thing goes — the follow-up list is not a someday-maybe pile.
- **Undecided is not the same as hidden.** "We need to just have that list." Open questions stay surfaced in the README even while unresolved.
- **A cluttered active view is the disease.** Superseded design docs sat in the same flat directory as the live spec, dead only by frontmatter. So done and superseded material moves out of the active view (with a SUPERSEDED banner on superseded docs); the active surface stays small.

## Quick start

```
# In your project root, with .context/ symlinked to your context repo
box new worker-backpressure          # create a box (or --pr / --issue to seed from someone's work)
box open worker-backpressure         # resume an existing box — reads the head, flags handoffs
box plan                             # lay out the work track — arranges, never executes
box spec 1                           # compose items/1/spec.md — what/why; open questions allowed
box do 1                             # execute item 1 — reads spec + plan, dispatches; explicit go only
box status                           # re-orient mid-session once the box is already open
box park "loader swallows version mismatches"   # capture a follow-up with a disposition
box note "we'll treat the PR as source of truth"  # lighter: a decision/discovery/open question into the log
box handoff                          # write a standalone carry-forward prompt into handoffs/
box pickup                           # resume from the latest handoff (box-aware)
box rollup                           # regenerate the README head from the source files
box migrate                          # bring an older box up to box_schema: 1.3
box close                            # reconcile every follow-up, archive done work, draft the PR
```

Most boxes stay small and quietly end. Abandoning is cheap — archive over delete. A stub box is one README; only a few grow large. Don't build structure before it's needed.

## The model

The core vocabulary (box, README, item, track, follow-up, disposition, log, projected zone, readiness checklist) is defined once in `SKILL.md` under Conventions — that's the authoritative version. The shape in brief: the README is an index over the items; each item lives at `items/<id>/` and carries up to two artefacts — `spec.md` (understanding, open questions allowed) then `plan.md` (agent-actionable, zero open questions). Not every item needs both: a spec is optional when there's nothing to discover.

A box is for *many* items — if a box reduces to one item it never needed to be a box. The opening move is to orient and decompose: the first item is usually a decomposition/design item whose job is to cut the work into the others.

The README/Log split is deliberate — navigation versus narrative, two jobs. Don't collapse them into "context".

## Subcommand reference

See the table in `SKILL.md`. Each subcommand has a detailed protocol in `protocols/<name>.md`. The full verb set (14): `new`, `import`, `open`, `status`, `plan`, `spec`, `do`, `migrate`, `park`, `note`, `handoff`, `pickup`, `rollup`, `close`.

## Design decisions

The open questions from the original design brief, now settled:

- **Items are addressable units.** Each lives at `items/<id>/` with up to two artefacts; the README is an index over them, not a container of their bodies. (v1's single inline plan is superseded.)
- **Discovery is the `spec` verb.** The `needs-discovery → ready` transition is the spec→plan progression; an item moves to `ready` only when its open questions are cleared and the readiness checklist is ticked.
- **Rollup is manual only.** Source files are the truth; the projected zone is a view. No auto-trigger.
- **Carry-forward prompts live in the box** — `park` may offer one for future-session dispositions, and the first-class `handoff` verb produces the same artefact without a new `F<id>`. Both write to `handoffs/` inside the box, not the OS temp dir.
- **`close` drafts the PR description** — composes a draft from the box and prints it. Never posts.
- **Slash-arg parsing follows triage's convention** (first token = verb, rest = verbatim steer).

Inherited from triage:

- Static zone + projected zone in the README, delimited by markers, so `rollup` is safe to re-run.
- Append-only log — major transitions only, never edited after writing.
- Commit-before-edit on every state-modifying verb, scoped to the box's own paths.
- Discovery before commitment (≤5 tool calls) for any subagent that could run something long.
- Public artefacts never leak box vocabulary; draft only, never post unprompted.

## Open questions about the design

- [ ] Slash-arg parsing: does `box park <long text>` reliably pass the trailing text as args? If not, fall back to prefix-only invocation.
- [ ] Does `note`'s three-way classification (`decision` / `open-question` / `note`) earn its place, or do the distinctions blur in practice?
- [ ] Does the carry-forward handoff offer from `park` fire at the right moments, or too often / too rarely?
- [ ] Does `box status` give enough orientation to choose the next move? It's orientation only — not a pickup substitute and not meant to produce a resumable doc (that's `box handoff`).
- [ ] Should `rollup` ever auto-trigger (e.g. after a burst of parks), or stay strictly manual?

(Resolved items from earlier rounds are recorded in `CHANGELOG.md`.)

## What's deliberately NOT built

- **A persistent agentic execution loop** — the `run.sh` / `queue.json` driver fan-out. `do` is a per-invocation dispatcher for one item, not an unattended queue-drainer; the persistent loop is its own future body of work.
- **Cross-box coordination** — one box, one body of work. Boxes may reference each other; nothing coordinates above them.
- **Triage fold-in** — triage stays its own skill until box proves out, then folds in as a bug-investigation flavour.
- **Beads integration** — out of scope for this skill.

## Related skills

- **`handoff`** (standalone skill) — the box-blind, context-agnostic carry-forward writer. Inside a box, use `box handoff` instead: it writes to the box's `handoffs/` directory, logs the event, and bakes in a resume protocol that tells the next session to load the box skill.
- **`pickup`** (standalone skill) — the box-blind resume tool. Inside a box, use `box pickup` instead: it loads the box vocabulary first, so `F<id>`, `Q<id>`, and the projected zone are all interpretable when the handoff is acted on.
- **`triage`** — the predecessor box generalises. Folds in later; left untouched for now.
- **`slice` / `work-bd` / `beads`** — the optional downstream chain. A ready item's `plan.md` can emit a `bd` issue; `do` executes a single item directly. The persistent drain loop comes later.

## Origin

Designed from the brief at `30-39 Technical Notes & Reference/30.06 Tools & Resources/box-skill-design.md`, itself grounded in the `Lightning.Adaptors` rewrite research. Built 2026-06-04; extended to v1.3 (spec/plan split, item folders, `do` & `migrate`) on 2026-06-10; prose rewrite to v2.0 on 2026-06-12. See `CHANGELOG.md` for the version history.

If something in this skill feels wrong or surprising on a real box, that's the signal — the design decisions above were best guesses, not certainties.
