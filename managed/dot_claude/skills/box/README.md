# Box skill

A file-first work-driver for a single multi-day or multi-week body of work. The box is disk; the live session is RAM. One box = one contained body of work — a durable spine that holds the plan, the parked follow-ups, the provenance, and the always-current head, so a fresh session opens the box and is loaded without surgically reconstructing context. The format scales stub → tome without restructuring: a freshly-born box is one README with the plan inline; structure accretes on demand.

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
box plan                             # lay out the work track — arranges, never executes
box status                           # read-only orientation; the conversational front door
box park "loader swallows version mismatches"   # the headline gesture — capture + disposition
box note "we'll treat the PR as source of truth"  # lighter: a decision/discovery/open-question into the Log
box rollup                           # regenerate the README head from the source files
box close                            # reconcile every follow-up, demote done work, draft the PR
```

Most boxes stay small and quietly die. Abandoning is cheap — archive over delete. A stub box is one README; only a few grow to thousands of lines. Don't build the cathedral.

## The model

Five plain words, all drawn from artefacts Stu already hand-rolled.

- **Box** — the container; one body of work. The folder.
- **README** — the head: always-current navigation (state, current-vs-superseded document map, next moves, open follow-ups, open questions), ~100 lines.
- **Plan** — the work track: ordered, intent-level items, each with a state. Born inline in the README; splits to `plan.md` on demand.
- **Follow-ups** — the parked track: each entry carries a disposition naming where it goes.
- **Log** — append-only provenance and narrative: what happened, decisions, open questions.

The README/Log split is deliberate — navigation versus narrative, two jobs. Don't collapse them into "context".

## Subcommand reference

See the table in `SKILL.md`. Each subcommand has a detailed protocol in `protocols/<name>.md` — `new`, `status`, `plan`, `park`, `note`, `rollup`, `close`.

## Design decisions

The six open questions from the design brief, now locked (full detail in `SKILL.md` under "Resolved design decisions"):

- **Plan is born inline in the README**, and the `plan` verb migrates it to `plan.md` only once it exceeds ~12–15 items or crowds the head. One-way, on demand.
- **No discovery verb in v1** — the `needs-discovery → ready` transition is conversational; you dispatch tracing agents in the moment you reach the item.
- **Rollup is manual only.** Source files are the truth; the projected zone is a view. No auto-trigger.
- **Carry-forward prompts live in the box** — `park` writes them to a lazily-created `handoffs/` subdir, reusing the `handoff` format but persisting it in the durable record rather than the OS temp dir.
- **`close` drafts the PR description** — composes a draft from the box and prints it. Never posts.
- **Slash-arg parsing follows triage's convention** (first token = verb, rest = verbatim steer). Treated as unconfirmed until verified on real use.

Inherited from triage and worth restating:

- **Static zone + projected zone in the README**, delimited by `<!-- BOX: BEGIN PROJECTED -->` / `<!-- BOX: END PROJECTED -->`, so `rollup` is safe to re-run and never touches the hand-curated top.
- **Append-only Log** — major transitions only, never edited after writing.
- **Commit-before-edit** baked into every state-modifying verb; stop and ask if the tree has unrelated changes.
- **Discovery before commitment** — any subagent that could run something long spends ≤5 tool calls confirming the data shape first.
- **Public artefacts never leak the box** — no follow-up IDs, slugs, or internal pointers cross to a GitHub issue or PR description; and per the standing rule, draft only, never post unprompted.

## Refinements for v1 → v2

Tick these off as you confirm them on the first real boxes.

- [ ] `allowed-tools` glob match: do the scoped `Bash(git -C * …)` patterns actually fire on `.context/` repo paths containing slashes? Confirm via `/doctor` or a live prompt; if the multi-`*` form fails to match, fall back to `Bash(git -C *)`.
- [ ] Q-resolution visibility in `status`: `status` reads only the last ~10 `log/` filenames, so a `question-resolved` event can fall outside the window and leave a question showing as open. Accept the "run `box rollup` if counts look off" note, or widen the scan?
- [ ] Slash-arg parsing: does `box park <long text>` reliably pass the trailing text as args? If not, fall back to prefix-only invocation.
- [ ] Does the inline → `plan.md` split threshold (~12–15 items) feel right, or does it split too early / too late?
- [ ] Does `note`'s three-way classification (`decision` / `open-question` / `note`) earn its keep, or do the distinctions blur in practice?
- [ ] Does the carry-forward handoff offer fire at the right moments (future-session dispositions), or too often / too rarely?
- [ ] Is `box status` alone enough orientation to skip `/pickup` on a fresh session? If yes, document the substitution.
- [ ] Should `rollup` ever auto-trigger (e.g. after a burst of parks), or stay strictly manual?

## What's deliberately NOT built (v1)

- **The agentic execution loop** — the `run.sh` / `queue.json` / driver fan-out harness. The box *feeds* it later but does not contain it. (This is why `work-bd` has been useless so far — no spine feeds it. The box is that spine; the loop comes after.)
- **Cross-box / portfolio machinery** — one box, one body of work. Boxes may reference each other; nothing coordinates above them.
- **Triage fold-in** — triage stays its own skill until box proves out, then folds in as a bug-investigation flavour.
- **The beads projection** — the box owns the whole climb; beads only ever sees the ready top rungs, and not yet.

The box is the spine that feeds those later. v1 earns them first.

## Related skills

- **`handoff`** — park's carry-forward prompt *is* a handoff scoped to a box; it reuses the format but persists it inside the box (`handoffs/`) rather than the OS temp dir.
- **`pickup`** — can open a box by reading its README. `box status` is the faster, read-only alternative when there's no handoff.
- **`triage`** — the embryo box generalises. Folds in later; left untouched for now.
- **`slice` / `work-bd` / `beads`** — the optional downstream ladder. Not in v1; a ready plan item can emit a `bd` issue once the loop is built.

## Origin

Designed from the brief at `30-39 Technical Notes & Reference/30.06 Tools & Resources/box-skill-design.md`, itself grounded in the `Lightning.Adaptors` rewrite research (the artefacts folder and the archived interactive sessions). Built 2026-06-04.

If something in this skill feels wrong or surprising on the first real box, that's the signal — the design decisions above were best-guesses, not load-bearing certainties.
