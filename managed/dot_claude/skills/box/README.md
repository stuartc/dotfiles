# Box skill

A file-first work-driver for a single multi-day or multi-week body of work. The box is disk; the live session is RAM. One box = one contained body of work — a durable spine that holds the plan, the parked follow-ups, the provenance, and the always-current head, so a fresh session opens the box and is loaded without surgically reconstructing context. The format scales stub → tome without restructuring: a freshly-born box is one README — a projected index over an empty track; structure accretes on demand as items earn folders under `items/<id>/`.

`SKILL.md` is the operational spec Claude reads. This README is for Stu.

## Why this exists

Validated against the real `Lightning.Adaptors` rewrite: a 7-week, 5-burst project, ~13k lines of artefacts across ~45 docs. Two research passes — a structural read of the artefacts folder and a fan-out over the interactive sessions reading the verbatim prompts — surfaced the load-bearing findings that shaped the design:

- **The head-of-box is the highest-value artefact, and it was missing for six weeks.** The `00-SESSION-BOOTSTRAP.md` was hand-built only near the end. "I don't want to surgically recreate good context every session." So the skill *owns* keeping the head fresh — it doesn't rely on discipline.
- **Park is a session boundary, not a mid-flow micro-eject.** The dominant real behaviour is *commit what we have, then write a prompt to resume in another session*. So the headline gesture fuses follow-up capture with a carry-forward handoff.
- **Stu speaks disposal, not deferral.** "bin it", "leave it dead until phase c". Every park names *where it goes* — the follow-up track is not a someday-maybe limbo.
- **Undecided is not the same as hidden.** "We need to just have that list." Open questions stay surfaced in the README even while unresolved. Visibility over tidiness.
- **Pollution is the disease.** Superseded design docs sat in the same flat directory as the live spec, dead only by frontmatter. So done and superseded material is demoted out of the active view with a death-banner; the active surface stays small.

## Quick start

```
# In your project root, with .context/ symlinked to your context repo
box new worker-backpressure          # open a box (or --pr / --issue to seed from someone's work)
box open worker-backpressure         # resume an existing box — loads vocab, reads head, flags handoffs
box plan                             # lay out the work track — arranges, never executes
box status                           # re-orient mid-session once the box is already open
box park "loader swallows version mismatches"   # the headline gesture — capture + disposition
box note "we'll treat the PR as source of truth"  # lighter: a decision/discovery/open-question into the Log
box handoff                          # write a standalone carry-forward prompt into handoffs/
box pickup                           # resume from the latest handoff (box-aware, vocabulary loaded)
box rollup                           # regenerate the README head from the source files
box close                            # reconcile every follow-up, demote done work, draft the PR
```

Most boxes stay small and quietly die. Abandoning is cheap — archive over delete. A stub box is one README; only a few grow to thousands of lines. Don't build the cathedral.

## The model

Five plain words, all drawn from artefacts Stu already hand-rolled.

- **Box** — the container; one body of work. The folder.
- **README** — the head: always-current navigation (state, current-vs-superseded document map, next moves, open follow-ups, open questions), ~100 lines.
- **Plan** — the work track: ordered, intent-level items, each with a state. Per item, at `items/<id>/plan.md`, once the item is `ready`.
- **Follow-ups** — the parked track: each entry carries a disposition naming where it goes.
- **Log** — append-only provenance and narrative: what happened, decisions, open questions.

v1.3 adds the **item** as the unit of work. A box is for *many* items — the items, plural, are the work; if a box reduces to one item it never needed to be a box. So the opening move is to orient and decompose, not to mint one big item: the first item is usually a decomposition/design item whose job is to project the others. Each item lives at `items/<id>/` and graduates through up to two artefacts — `spec.md` (understanding, open questions allowed) then `plan.md` (agent-actionable, zero open questions). Not every item needs both: spec is optional when there is nothing to discover.

The README/Log split is deliberate — navigation versus narrative, two jobs. Don't collapse them into "context".

## Subcommand reference

See the table in `SKILL.md`. Each subcommand has a detailed protocol in `protocols/<name>.md`. The full verb set (13) is: `new`, `open`, `status`, `plan`, `spec`, `do`, `migrate`, `park`, `note`, `handoff`, `pickup`, `rollup`, `close`.

Key additions in v1.3: the unit of work is now the **item** at `items/<id>/`, each with up to two artefacts — `spec` (what/why and the load-bearing how; open questions allowed) and `plan` (agent-actionable; zero open questions). `do <id>` is the resourceful executor that reads both and dispatches. `migrate` brings an older box up to `box_schema: 1.3`. `plan` is box-native now (no Claude Code plan mode) and still exits with three doors. (v1.2 added `open`, `handoff`, `pickup`.)

## Design decisions

The six open questions from the design brief, now locked (full detail in `SKILL.md` under "Resolved design decisions"):

- **Items are addressable units.** Each lives at `items/<id>/` with up to two artefacts (`spec.md`, then `plan.md`); the README is a projected index over them, not a container of their bodies. (v1's single inline plan splitting to `plan.md` is superseded.)
- **Discovery is the `spec` verb.** The `needs-discovery → ready` transition is the spec→plan progression; a spec graduates only when its open questions are cleared and the readiness checklist is ticked.
- **Rollup is manual only.** Source files are the truth; the projected zone is a view. No auto-trigger.
- **Carry-forward prompts live in the box** — `park` may offer one for future-session dispositions, and the first-class `handoff` verb produces the same artefact without a new `F<id>`. Both write to `handoffs/` inside the box (the durable record), not the OS temp dir.
- **`close` drafts the PR description** — composes a draft from the box and prints it. Never posts.
- **Slash-arg parsing follows triage's convention** (first token = verb, rest = verbatim steer). Treated as unconfirmed until verified on real use.

Inherited from triage and worth restating:

- **Static zone + projected zone in the README**, delimited by `<!-- BOX: BEGIN PROJECTED -->` / `<!-- BOX: END PROJECTED -->`, so `rollup` is safe to re-run and never touches the hand-curated top.
- **Append-only Log** — major transitions only, never edited after writing.
- **Commit-before-edit** baked into every state-modifying verb; stop and ask if the tree has unrelated changes.
- **Discovery before commitment** — any subagent that could run something long spends ≤5 tool calls confirming the data shape first.
- **Public artefacts never leak the box** — no follow-up IDs, slugs, or internal pointers cross to a GitHub issue or PR description; and per the standing rule, draft only, never post unprompted.

## Refinements for v1 → v2

Items ticked or annotated were addressed in v1.2.

- [x] `allowed-tools` glob match: do the scoped `Bash(git -C * …)` patterns actually fire on `.context/` repo paths containing slashes? — **Resolved by reframing (v1.2):** these globs only matter outside `bypassPermissions`/`acceptEdits` mode. In Stu's normal setup they are moot; in default-permission/headless/cron/other-user runs the globs remain as scoped as possible. No functional change; the comment in `SKILL.md` now reflects this.
- [x] Discoverability: the verb set was not visible until you typed `/box` with no args. — **Addressed (v1.2):** `argument-hint` now lists all ten verbs at a glance.
- [x] Planning approach: was routing to the legacy `/create-plan` skill. — **Addressed (v1.2):** `plan` now uses Claude Code's native plan mode for non-trivial planning; `/create-plan` is explicitly marked legacy and not routed to. — **Superseded (v1.3):** `plan` is box-native composition now; neither `/create-plan` nor Claude Code plan mode is used.
- [ ] Q-resolution visibility in `status`: `status` reads only the last ~10 `log/` filenames, so a `question-resolved` event can fall outside the window and leave a question showing as open. Accept the "run `box rollup` if counts look off" note, or widen the scan?
- [ ] Slash-arg parsing: does `box park <long text>` reliably pass the trailing text as args? If not, fall back to prefix-only invocation.
- [x] Inline → `plan.md` split threshold. — **Moot (v1.3):** plan is per-item at `items/<id>/plan.md`; there is no inline-plan split any more.
- [ ] Does `note`'s three-way classification (`decision` / `open-question` / `note`) earn its keep, or do the distinctions blur in practice?
- [ ] Does the carry-forward handoff offer from `park` fire at the right moments (future-session dispositions), or too often / too rarely?
- [ ] Does `box status` hydrate you well enough to get your bearings before you choose your own next move? It's orientation only — *not* a pickup substitute and not meant to produce a resume-able doc (that's `box handoff`). Confirm the hydration is enough; the decision stays yours.
- [ ] Should `rollup` ever auto-trigger (e.g. after a burst of parks), or stay strictly manual?

## What's deliberately NOT built

- **A persistent agentic execution loop** — the `run.sh` / `queue.json` driver fan-out. Deferred. `do` is a per-invocation dispatcher for one item, not an unattended queue-drainer; the persistent loop is still its own future box. (This is why `work-bd` has been thin — no spine fed it; the box is that spine, `do` is the per-item executor, the loop comes after.)
- **Cross-box / portfolio machinery** — one box, one body of work. Boxes may reference each other; nothing coordinates above them.
- **Triage fold-in** — triage stays its own skill until box proves out, then folds in as a bug-investigation flavour.
- **The beads projection** — the box owns the whole climb; beads only ever sees the ready top rungs, and not yet.

The box is the spine that feeds those later; `do` is the first rung of execution, the persistent loop is still earned later.

## Related skills

- **`handoff`** (standalone skill) — the box-blind, context-agnostic carry-forward writer. Inside a box, use `box handoff` instead: it writes to the box's `handoffs/` directory, logs the event, and bakes a resume protocol that tells the next session to load the box skill. The standalone `/handoff` knows nothing about box vocabulary and produces an orphaned file outside the box.
- **`pickup`** (standalone skill) — the box-blind, context-agnostic resume tool. Inside a box, use `box pickup` instead: it loads vocabulary first, so `F<id>`, `Q<id>`, projected-zone markers, and `box plan` are all in context when the handoff is acted on. The standalone `/pickup` misses all of that. Neither is a peer of `box status`: `status` is a mid-session re-orient; it does not produce a resume-able document. That's `box handoff`'s job.
- **`triage`** — the embryo box generalises. Folds in later; left untouched for now.
- **`slice` / `work-bd` / `beads`** — the optional downstream ladder. A ready item's `plan.md` can emit a `bd` issue; `do` executes a single item directly. The persistent drain loop is still later.

## Origin

Designed from the brief at `30-39 Technical Notes & Reference/30.06 Tools & Resources/box-skill-design.md`, itself grounded in the `Lightning.Adaptors` rewrite research (the artefacts folder and the archived interactive sessions). Built 2026-06-04. See `CHANGELOG.md` for the version history. Extended to v1.3 (spec/plan split, item folders, `do` & `migrate`) on 2026-06-10.

If something in this skill feels wrong or surprising on the first real box, that's the signal — the design decisions above were best-guesses, not load-bearing certainties.
