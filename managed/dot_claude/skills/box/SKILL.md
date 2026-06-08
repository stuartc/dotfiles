---
name: box
description: A file-first work-driver for a single multi-day/week body of work. Use when work spans sessions and needs a durable spine that outlives session churn — the box is the continuity layer the disposable session leans on.
argument-hint: "new · open · status · plan · park · note · handoff · pickup · rollup · close"
# Scoped git pre-approval for the commit-before-edit convention. Only matters
# outside bypassPermissions/acceptEdits mode — in Stu's normal setup these are
# largely moot, but they narrow tool exposure for default-permission runs,
# headless/cron contexts, and other users.
allowed-tools:
  - "Bash(git -C * add -A)"
  - "Bash(git -C * commit -m *)"
  - "Bash(git -C * status --porcelain)"
  - "Bash(readlink -f *)"
  - "Bash(greadlink -f *)"
---

# Box

Multi-day work outlives the session it's done in. A live Claude session is RAM: disposable, ejected around 140–180k tokens. The box is disk: the continuity layer that survives the churn. One box = one contained body of work. You open the box and you're loaded — no surgical context reconstruction every fresh session.

The core idea, inherited from `triage`: the main session is a **dispatcher with a typed vocabulary**. Each subcommand reads its `protocols/<name>.md` and produces a named artefact in a predictable place. History is append-only. The README is a thin, always-current index — not the substance. In v1, all verbs run inline — no subagents are dispatched; the dispatch-shape rules below apply when a protocol does fork one, and to any in-session discovery agents.

The format scales **stub → tome without restructuring**. A freshly-born box is one README with the plan inline. Structure accretes on demand; you never restructure.

## What it is

A box does five jobs, in priority order:

1. **Drive the work** — hold an ordered plan of the next few things, some crisp, some marked `needs-discovery` and fleshed out only when you arrive at them.
2. **Capture with discipline** — when something surfaces mid-flow, park it cheaply with a disposition instead of polluting the session or forgetting it.
3. **Archive without polluting** — demote done/superseded work *out of the active view* while preserving it; keep open questions *visible*.
4. **Preserve provenance** — the lineage of how the work came to be.
5. **Bootstrap the next session** — the box *is* the rich start.

It generalises `triage` from bug-investigation to general work. Triage folds in as a flavour later — not in v1. Build box fresh; leave triage untouched.

## When to use

- A body of work that spans days or weeks and several sessions.
- Work that needs a durable spine — a plan you return to, follow-ups you park, provenance you keep.
- Taking over someone else's in-flight work (seed a box from a PR or issue).
- A homeless prompt that has grown into something worth keeping — materialise the box the instant it's worth keeping.

## When NOT to use

- A task you finish in one session — just do it.
- A production bug investigation — use `triage`.
- A meeting note or write-up — use the workbook.
- Portfolio coordination across many bodies of work — out of scope. One box, one body of work.

## Working layout (stub → tome)

A freshly-born box is **just `README.md`** with the plan inline. Structure accretes on demand — never restructure.

```
<slug>/
├── README.md          # the head: static top + projected "where things stand". Plan lives inline here until it splits.
├── plan.md            # the work track — split out of the README on demand, once it outgrows the head
├── follow-ups.md      # the parked track — created on first park
├── log/               # append-only events + decisions — created on the 2nd entry
│   └── 2026-06-04T09-10-born.md
├── handoffs/          # carry-forward prompts — created lazily on the first carry-forward
└── archive/           # demoted superseded docs, each with a death-banner
```

**Location:** `.context/stuart/boxes/<slug>/` in the current project (parallel to triage's `investigations/`). Assume `.context/` exists; **ask or refuse** if it genuinely doesn't. "Homeless" never means *outside a repo* — it means *in a repo with `.context/`, but the session started without a box open*.

## Subcommand vocabulary

| Verb | Purpose | Produces | Protocol |
|---|---|---|---|
| `new <slug> [--pr REF \| --issue REF]` | Open a box. Backfill origin from the live session, **or** seed from a PR/issue. Scaffold README (+ first Log entry). | box tree | `protocols/new.md` |
| `open [path]` | Resume an existing box: resolve the box root (explicit path, or most-recently-modified box), load vocabulary, read the README head, flag any handoffs, and orient. The explicit front door for picking a box back up across sessions. | conversation only | `protocols/open.md` |
| `status` | Read-only orientation — re-orients when the box is already open. Prints the README head: state, next moves, open follow-ups, open questions. No edits. | conversation only | `protocols/status.md` |
| `plan` | Work the plan: add/reorder items, set states. `plan next` pulls the next `ready` item. For non-trivial planning, uses Claude Code's native plan mode (inheriting Stu's global planning conventions — fresh agents per logical phase, etc.). After planning, offers three doors: action now / write into the box / just discuss. Light edits (add/reorder one item, flip a state) stay inline. Split plan to `plan.md` when it outgrows the head. | inline `## Plan` or `plan.md` | `protocols/plan.md` |
| `park <text>` | **The headline gesture.** Capture a follow-up with a disposition; if it's a future-session thing, offer the carry-forward prompt. | `follow-ups.md` entry (+ optional handoff) | `protocols/park.md` |
| `note <text>` | Log a decision / discovery / open question. Lighter than park — no disposition. | `log/` entry | `protocols/note.md` |
| `handoff [text]` | Write a standalone carry-forward prompt into `handoffs/`, with a box-aware resume protocol baked in. A first-class verb; `park` may also emit one for future-session dispositions. | `handoffs/` entry + `handoff` Log event | `protocols/handoff.md` |
| `pickup [path]` | Box-aware resume from a handoff (defaults to the latest in `handoffs/`): load vocabulary, read the handoff + README head, orient, and treat the handoff as a brief to act on. The box-flavoured pickup — unlike the standalone `/pickup`, which is box-blind. | conversation only | `protocols/pickup.md` |
| `rollup` | Regenerate the README projected zone from plan/follow-ups/log. Demote done & superseded material out of the active view. | updated README | `protocols/rollup.md` |
| `close` | End-of-box: reconcile every open follow-up, demote done work to `archive/`, record terminal state, draft the PR description. | closing Log entry + README | `protocols/close.md` |

## Routing

Parse the **first token** of the argument as the subcommand. Everything after it is optional **steer**: pass it verbatim to the dispatched agent as extra context, don't ignore it.

For each subcommand, **read the corresponding `${CLAUDE_SKILL_DIR}/protocols/<name>.md` file** and follow it. The protocol files hold the dispatch templates and step-by-step rules. Don't try to remember them from this index.

If the subcommand is unrecognised, list the vocabulary back to the user and ask.

**Conversational on top of explicit.** Stu's real invocation style is conversational: he opens a box (`box open <path>` or `box pickup <handoff>`) then describes the situation in natural language and lets the dispatcher route it. Support that — explicit verbs underneath, smart routing on top. When he describes a situation rather than naming a verb, infer the verb (a thing to park → `park`; a decision made → `note`; "where are we" → `status`; "what's next" → `plan next`; "resume / where was I / pick the box back up" → `open`; "write a handoff / carry this forward" → `handoff`; "pick up from <handoff>" → `pickup`) and proceed, confirming only when genuinely ambiguous.

## Conventions across all subcommands

**Box root resolution.** Resolve once per invocation: `.context/stuart/boxes/<slug>/` relative to `pwd`. If the user pointed at a box (`box is here: <path>`), use that. If no slug context exists yet (first call wasn't `new`), use the most-recently-modified box under `.context/stuart/boxes/`, or ask if it's ambiguous.

**Vocabulary.** Five plain words. Do not collapse the README/Log split into "context" — they do two different jobs.

- **Box** — the container; one body of work. The folder.
- **README** — the head: always-current navigation. State, current-vs-superseded document map, next moves, open follow-ups, open questions. ~100 lines, always current.
- **Plan** — the work track: ordered, intent-level items, each with a state. Lives inline in the README until it splits to `plan.md`.
- **Follow-ups** — the parked track: each entry carries a disposition naming where it goes. In `follow-ups.md`.
- **Log** — append-only provenance and narrative: what happened, decisions, open questions. Can be long. In `log/`.

**Plan item states.** `stub` (placeholder, `<TODO: spec out>`) → `needs-discovery` (known but not understood; engage when reached) → `ready` (crisp, actionable) → `done`. The `needs-discovery → ready` transition is where discovery happens — for v1 this is **conversational, no dedicated verb**. You dispatch discovery agents in the moment when you reach the item. There's no stored "in-progress" tag: "currently working an item" is conveyed by the live session plus any carry-forward handoff, not a state on the item.

**Follow-up dispositions.** Every park names where it goes — disposal language, not deferral. `in-scope-later` (do during this box, on the tail) / `→ issue` (becomes a GitHub issue, provenance linked back) / `→ new box` / `dropped` (explicitly killed, with a reason). At `close`, **every open follow-up reconciles to a terminal disposition** — that's the normal ending for a box, not an edge case.

**Follow-up IDs.** `F1`, `F2`, … — assigned by `park`, **never reused, never renumbered**. A dropped or spun-out follow-up keeps its ID forever. Entries live in `follow-ups.md`, each carrying enough context to make sense in five days without re-discovery.

**Open-question IDs.** `Q1`, `Q2`, … — assigned by `note` when the type is `open-question`, **never reused, never renumbered**. A resolved question keeps its ID forever. The authoritative source for the highest `Q`-ID and the resolved set is the `log/` filenames (`…-open-question-Q<n>.md` raised, `…-question-resolved-Q<n>.md` settled) — the README projected zone is a lagging view. Resolution is **conversational, not a verb**: when Stu's text settles a question, the `Q<id>` in it is the dispatch signal and the resolution lands as a `question-resolved:Q<id>` Log event.

**Event log.** Append-only, never edited. One short file per major transition, named `YYYY-MM-DDTHH-MM-<event-type>.md`, usually 5–20 lines: timestamp, what changed, pointer to the artefact, one line of context. Only log when state Stu cares about has shifted — not every edit. **Filename rule for parameterised types:** the `:` in an event type renders as `-` in the filename (colons in filenames are a portability footgun), ID suffix retained — `question-resolved:Q3` → `…-question-resolved-Q3.md`, `followup-parked:F1` → `…-followup-parked-F1.md`. The hyphenated form is what `rollup` scans for. Event types:

- `born` — box created
- `seeded-from-pr` / `seeded-from-issue` — box seeded from a public ref
- `plan-updated` — plan items added / reordered / state-changed
- `followup-parked:F<id>` — one event per park (or one covering several parked together)
- `note` — a logged decision / discovery / observation
- `decision` — a decision recorded
- `open-question:Q<id>` — an unresolved question raised (the `Q<id>` is assigned at creation, never reused or renumbered; stays visible in the README until settled)
- `question-resolved:Q<id>` — a previously-raised question settled (drops off the README, lives in the Log forever)
- `rolled-up` — README projected zone regenerated
- `handoff` — a carry-forward prompt written (points at the `handoffs/` file)
- `superseded:<doc>` — a document demoted to `archive/`
- `closed` — box closed, terminal state recorded

**Commit-before-edit.** Baked into every state-modifying verb (`plan`, `park`, `note`, `rollup`, `close`). Before the edit, stage and commit the current state with a generic message: `box: snapshot before <verb>`; after the edit, commit `box: <verb> <slug>`. `new` is the exception — there's no prior state to snapshot, so it commits just once after scaffolding (`box: new <slug>`), giving the box birth a clean boundary in the history. No co-author lines, no skip-hooks. If the working tree has **unrelated** changes, **stop and ask** rather than sweeping them in.

`.context/` is usually its own git repo, often a symlink. Run git against the resolved repo root with `-C` — **do NOT `cd` into the target**, because a command starting with `cd` can never be pre-approved. Resolve the repo root once per invocation: `CONTEXT_REPO=$(readlink -f .context)` (use `greadlink -f` if `readlink -f` is unavailable; it's native on macOS 12.3+). Then `git -C "$CONTEXT_REPO" add -A` and `git -C "$CONTEXT_REPO" commit -m "box: <verb> <slug>"`. If `.context/` isn't a git repo, skip the commit and tell the user.

**Clean-tree skip.** If `git -C "$CONTEXT_REPO" status --porcelain` is empty, skip the snapshot commit silently and proceed to the edit. The clean-tree skip applies only to the snapshot step — unrelated changes still mean **stop and ask**.

**Discovery before commitment.** Any dispatched subagent about to run something potentially long (big SQL, codebase-wide grep, large fan-out, PR/issue fetch with pagination) **must** spend ≤5 tool calls confirming the data shape exists before committing to the work. This is the stuck-agent insurance.

**Subagent dispatch shape.** When a protocol dispatches a subagent, the brief always includes: (1) the box root path, (2) which specific files to read first, (3) the named artefact path it must produce, (4) the ≤5-line return format expected, (5) the discovery-before-commitment rule. Never dispatch with "go do X" — always with the artefact path and shape. If the subagent produces anything public-facing, pass it the leak-free rule below.

**Public artefacts never leak the box.** The box is a private working tool (it lives in a private context repo; most of the code it describes is open source). Anything that leaves the box for a public surface — a GitHub issue, a PR description, an external comment — must stand on its own in plain English and **must not** carry the box's internal vocabulary: no follow-up IDs (`F1`, `F2`), no slug references, no "the box found…", no `plan.md`/`follow-ups.md` pointers. Translate into how a person would naturally write it. And per Stu's standing rule, **draft only — never post to a public surface unprompted.**

**Projected-zone markers.** The README has a hand-curated static zone and a regenerated projected zone, delimited by:

```
<!-- BOX: BEGIN PROJECTED -->
…
<!-- BOX: END PROJECTED -->
```

`rollup` only ever replaces the content **between** the markers. The static zone above is hand-curated and never touched by rollup. If the markers are missing, warn and ask before reconstructing.

## Resolved design decisions

These were open questions in the design brief; they are now locked.

1. **Plan is born inline in the README.** The `plan` verb migrates it to `plan.md` only once it exceeds ~12–15 items or visibly crowds the head. One-way split, on demand — once split, it stays in `plan.md`.
2. **No discovery verb in v1.** The `needs-discovery → ready` transition is conversational.
3. **Rollup is manual only.** Source files (`plan`, `follow-ups.md`, `log/`) are the truth; the projected zone is a view. No auto-trigger.
4. **Carry-forward prompts live in the box.** `park` writes them to a lazily-created `handoffs/` subdir; a short `handoff` Log event points at the file. This reuses the `handoff` skill's format but persists it in the box (the durable record), not the OS temp dir.
5. **`close` drafts the PR description.** It composes a PR-description **draft** from the box and prints it for Stu to send — never posts.
6. **Slash-arg parsing follows triage's convention** (first token = verb, the rest = verbatim steer). Treat as unconfirmed; verify on first real use and fall back to prefix-only invocation if trailing text doesn't arrive.

## Pickup ergonomics

The explicit front doors for picking a box back up across sessions are `box open <path>` and `box pickup <handoff>`. Both load the box vocabulary and hydrate you before handing the next move back.

**The trio, clearly:**

- `box open [path]` — resolves the box root, reads the README head, flags any handoffs, and orients. Use when you're returning to a box in general and don't have a specific handoff to resume from.
- `box pickup [path]` — like `open`, but leads with a specific handoff doc (defaults to the latest in `handoffs/`). Treats the handoff as a brief to act on, not just a summary to acknowledge. The box-flavoured pickup — because it loads the box vocabulary first, it knows what a follow-up ID or plan state means. The standalone `/pickup` is box-blind and misses that.
- `box status` — re-orients when the box is already open in the current session. Prints the one-line state, next moves, open follow-ups, and open questions. Lighter than `open`; use it for mid-session bearings.

All three are orientation only — they hydrate and hand the next move back to you. Deciding what to do next is deliberately the human's job. Making a resume-able document is `box handoff`'s job (or `park`'s carry-forward offer); none of the resume verbs manufacture one on your behalf.

## Style

- British English in scaffolded files.
- No emoji.
- Short, opinionated, complete sentences.
- File templates use Markdown; YAML frontmatter only where a field is load-bearing (e.g. `superseded_by:` on demoted docs).
- No back-references in artefacts ("as discussed earlier") — every artefact stands alone or links explicitly.

## Out of scope (v1)

- **The agentic execution loop.** The `run.sh` / `queue.json` / driver fan-out harness is its own beast. The box *feeds* it later but does not contain it.
- **Cross-box / portfolio machinery.** One box, one body of work. Boxes may reference each other; nothing coordinates above them.
- **Triage migration.** Fold triage in once box has proven out.
- **The beads projection.** The box owns the whole climb; beads only ever sees the ready top rungs — and not in v1.
