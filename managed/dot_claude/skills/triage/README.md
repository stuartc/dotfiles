# Triage skill

Multi-session bug triage with named artefacts, theory lifecycle, and append-only history. For production bug investigations that span multiple sessions and need to stay legible as they grow.

`SKILL.md` is the operational spec Claude reads. This README is for Stu.

## Why this exists

Two May 2026 investigations went sideways in the same way: a single README ballooned to 700–800 lines, theories got silently overwritten or buried under `SUPERSEDED` banners, and starting a fresh session meant pointing at the mess and crossing fingers. Diagnostic agents found:

- The README was doing four jobs at once (orientation, evidence, theory, fix)
- The cleanest artefacts were *bounded subfolders* with pre-scoped questions, 1 file per question, and a synthesis written last
- Handoffs got called mid-session and became a second accumulation target diverging from the README
- Inline work that should have been farmed off filled the main session's context
- One subagent burned 10 hours in a Sentry pagination loop because it skipped discovery

This skill encodes the patterns that worked and forbids the ones that didn't.

## Quick start

```
# In your project root, with .context/ symlinked to your context repo
/triage init wg-shape-investigations --sentry LIGHTNING-3F9
/triage scope                       # how widespread is this
/triage taxonomy                    # if multiple error shapes exist
/triage hypothesise                 # propose theories (or fire with text)
/triage probe T02                   # write probe + discovery, run or hand back
/triage findings T02                # interpret .out, write verdict
/triage fix-spec T02                # draft fix for confirmed theory
/triage rollup                      # regenerate README projected zone
/triage status                      # read-only orientation, no edits
```

Most investigations skip `taxonomy` (only needed when shapes are lumped). Many skip `scope` too. The vocabulary is intentionally optional past `init`.

## Subcommand reference

See the table in `SKILL.md`. Each subcommand has a detailed protocol in `protocols/<name>.md`.

## Slash-command parsing — to confirm

Untested as of writing: when you fire `/triage probe T02 with extra steer text`, what arrives at the skill?

Convention used throughout the protocols: **first token after the subcommand is the target (eg. theory ID); everything else is optional steer passed verbatim to the dispatched agent.**

If Claude Code mid-message slash commands don't actually pass trailing text as args, fall back to prefix-only invocation (slash command at start of message) and put commentary on the line above or below.

## Design decisions

- **Static zone + projected zone in README** so `/triage rollup` is safe to re-run — never touches the hand-curated top
- **Flat numbered probes** (`probes/01.sql`, `02.iex`, …) — cross-theory probes are common; per-theory subfolders would force awkward refs
- **Event log records major transitions only** — theory state changes, probes run, shapes discovered, handoffs. Not every edit. Granularity matters.
- **Theory IDs are immutable** — `T01` stays `T01` even when falsified. Folders stick around. Supersession is a relationship between theories (logged as an event), not a rewrite.
- **Commit-before-edit** baked into every state-modifying protocol — addresses the "I forget to commit and can't recover" pain
- **Probe and findings are strictly separated** — probe writes the script + runs it (or hands back); findings interprets `.out`. A probe never pre-interprets. Findings never propose new theories.
- **Discovery before commitment** — every subagent that could run something long (Sentry pagination, big SQL, codebase grep) must spend ≤5 tool calls confirming the data shape before committing. This is the 10-hour-stuck-agent insurance.
- **Failing tests live in the project's test tree**, tagged `:reproduces_bug` so CI stays green. The investigation folder just holds a pointer note. Tests are project artefacts.
- **`.context/stuart/investigations/<slug>/` as default location** — follows the symlink convention. If `.context/` doesn't exist, the skill asks rather than guessing.
- **No auto-trigger for rollup** — you run `/triage rollup` when you want the README to reflect reality. Source files are truth; README is a view.
- **Static zone in README is hand-curated, not regenerated** — symptom and vocabulary are stable, projected state evolves

## Possible future: a `close` subcommand

Not built yet — captured here so the decision is informed rather than reflexive.

**The gap it would fill.** Every other lifecycle transition has a verb (`init`, `hypothesise`, `probe`, `findings`, `fix-spec`) but there's no verb for *ending* an investigation. Your own framing of the workflow was "evaluate the impact, then either drive to a fix or spin out concrete issues" — that's an explicit exit step, and right now it happens informally (a final commit, maybe a stray log entry) with nothing enforcing that loose ends are tied off.

**What `close` would do.** Roughly:

1. Require a terminal state and record it: `fixed` (links the `fix-spec` / PR), `spun-out` (the whole thing became other issues), `wont-fix` / `not-reproducible`, or `superseded-by <slug>`.
2. **Reconcile every open `F<id>` follow-up** — for each one, force a decision: spun out (to where — a `/triage init <slug>` or a GH issue URL) or explicitly dropped (with a reason). This is the real value: follow-ups are easy to park and easy to forget, and close is the moment they'd otherwise rot.
3. Sanity-check theory states — warn if theories are still `proposed` with no findings (an investigation closing with untested theories is worth a deliberate "yes, leaving those open" rather than silence).
4. Write a `closed` log event + a closing summary block in the README static zone, and do a final commit.

**When it earns its keep.** Once you've run a handful of these end-to-end and follow-ups are routinely being parked, the "did F2 ever get spun out?" question becomes real. If investigations mostly resolve to a fix and rarely accumulate follow-ups, a final commit plus a hand-written `closed:` log event is enough and `close` is ceremony. So: defer until the follow-up volume makes reconciliation a chore — that's the signal it's worth the protocol file.

The lighter-weight alternative (current state): when you close by hand, the closing log entry should call out each follow-up's fate. `followup.md` and the F-id convention both already say this.

## Refinements for v2

Tick these off as you confirm or resolve them on the next investigation.

- [ ] Slash-command arg parsing: does `/triage probe T02 with extra text` pass the extra text? Confirm and update protocols if needed
- [ ] Are `scope` and `taxonomy` meaningfully separate, or do they collapse into `init`?
- [ ] Is the `shapes:` frontmatter on theory briefs being used for anything past rollup display? If not, simplify
- [ ] Per-theory probe numbering (`theories/T02/probes/01.sql`) vs flat (`probes/01.sql`): does cross-theory referencing actually happen often enough to justify flat?
- [ ] Auto-rollup on every event append, or stay manual?
- [ ] Is the event log granularity right? Too noisy? Too sparse?
- [ ] Do the dispatched subagents actually obey the discovery rule, or does it need to be stricter / repeated in every protocol?
- [ ] Probe runner scripts: should `init` scaffold project-typed stubs (k8s, local, ssh) rather than just a `scripts/README.md`?
- [ ] Does `/triage status` give enough orientation to skip `/pickup` on fresh sessions? If yes, document the substitution.
- [ ] Is there a `close` subcommand needed, or is a final commit + a `closed:` event sufficient? (See "Possible future: a `close` subcommand" above — deferred until follow-up volume makes reconciliation a chore.)

## Related skills

- **`handoff`** — write a handoff doc when ending a session mid-investigation. Goes to the OS temp dir per its convention; reference investigation paths from inside the handoff.
- **`pickup`** — resume from a handoff. For triage sessions, `pickup` + reading the investigation README is the canonical fresh-session entry. `/triage status` is a faster, read-only alternative if no handoff exists.
- **`slice`** — once `fix-spec` is drafted, slice it into demoable PRs as `bd` issues. Natural next step after a confirmed theory has a spec.
- **`work-bd`** — drain the queue of fix slices once they're in beads.

## Origin

Designed 2026-05-27 after analysing two unwieldy investigations:

- `~/Sourcecode/worktrees/context/lightning/stuart/investigations/2026-05-26_run-channel-replied-with-error/`
- `~/Sourcecode/worktrees/context/thunderbolt/stuart/analysis/stuck-runs/`

Five diagnostic agents (git history, folder shape × 2, Claude session analysis × 2) surfaced the patterns that worked and the failure modes that recurred. An idea-machine pass generated five candidate architectures; this skill is a synthesis of the strongest threads from `phase-gated`, `evidence-log`, and `triage-ledger` — without the parts that felt over-engineered for a v1.

If something in this skill feels wrong or surprising on the next investigation, that's the signal — the design decisions above were best-guesses, not load-bearing certainties.
