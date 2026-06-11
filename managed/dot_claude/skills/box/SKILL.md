---
name: box
description: A file-first work-driver for a single multi-day/week body of work. Use when work spans sessions and needs a durable spine that outlives session churn — the box is the continuity layer the disposable session leans on.
argument-hint: "new · open · status · plan · spec · do · migrate · park · note · handoff · pickup · rollup · close"
# Scoped git pre-approval for the commit-before-edit convention. Only matters
# outside bypassPermissions/acceptEdits mode — in Stu's normal setup these are
# largely moot, but they narrow tool exposure for default-permission runs,
# headless/cron contexts, and other users.
allowed-tools:
  - "Bash(git -C * add -- *)"
  - "Bash(git -C * commit -m *)"
  - "Bash(git -C * status --porcelain -- *)"
  - "Bash(readlink -f *)"
  - "Bash(greadlink -f *)"
---

# Box

Multi-day work outlives the session it's done in. A live Claude session is RAM: disposable, ejected around 140–180k tokens. The box is disk: the continuity layer that survives the churn. One box = one contained body of work. You open the box and you're loaded — no surgical context reconstruction every fresh session.

The core idea, inherited from `triage`: the main session is a **dispatcher with a typed vocabulary**. Each subcommand reads its `protocols/<name>.md` and produces a named artefact in a predictable place. History is append-only. The README is a thin, always-current index — not the substance. Most verbs run inline; `spec` and `do` dispatch subagents (research fan-outs, executors), and the dispatch-shape rules below govern every fork — plus any in-session discovery agents.

The format scales **stub → tome without restructuring**. A freshly-born box is one README — a projected index over a work-track that is still empty. The unit of work is the **item**; each item that earns substance gets its own folder under `items/<id>/`. Structure accretes on demand; you never restructure. The README is a projected index *over* the items, never a container of their bodies.

## What it is

A box does five jobs, in priority order:

1. **Drive the work** — hold an ordered track of items, each carrying a *state*. Items are projected units of work, not a script — some still stubs, some `needs-discovery` (spec'd when you reach them), some `ready` (planned and actionable). A box is for *many* items; the track is the spine the session leans on.
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

## A box is for many items

A box exists because the work is **big**. The items, plural, *are* the work — the things to be done or covered. If a box ever reduces to one item → one spec → one plan, there was little point opening a box at all; that's just a task. So **do not be eager to mint a single all-encompassing item and march it through spec → plan → do.**

The opening move is to **orient and decompose**, not to record one big item. The cleanest model: **decomposition/design is itself the opening item** — the head item whose job is to understand the shape of the work and *project the other items*. Those projected items then graduate, individually, through `spec` → `plan` → `do`. An orienting first pass (a `findings/`-style bearings document) is the *output* of that opening work — bearings that tell you what the items are. The bearings need not be a first-class concept of the skill; the *step that produces them* is. `new` and `plan` steer toward this: when a box opens around something large, prompt to cut it up rather than recording a single item.

**Not every item needs both artefacts.** Spec is *optional* when there's nothing to discover — promote `stub → ready` and skip it. A review item may be spec-heavy with a thin plan; a mechanical item may be plan-only. The `plan` is the thing `do` runs against; the `spec` is the thing you write when *understanding* is the risk. Forcing both on every item re-introduces the ceremony the box exists to avoid.

## Working layout (stub → tome)

A freshly-born box is **just `README.md`** — a projected index over an empty track. Structure accretes on demand; everything that accretes is a *folder*. You never restructure.

```
<slug>/
├── README.md          # the head: static top + projected index (track + open follow-ups + open questions). Frontmatter: box_schema: 1.3
├── items/             # the work-track's bodies — created on the first non-stub item
│   └── <id>/
│       ├── spec.md    #   written at needs-discovery — what/why/some-how; open questions allowed
│       └── plan.md    #   written at ready — agent-actionable; zero open questions; phased
├── follow-ups/        # one file per parked follow-up (F<n>.md) — created on first park
│   └── F1.md
├── log/               # append-only events + decisions — created on the 2nd entry
│   └── 2026-06-04T09-10-born.md
├── handoffs/          # carry-forward prompts — created lazily on the first carry-forward
└── archive/           # demoted done/superseded items + docs, each with a death-banner
```

The README keeps a short **track** — the ordered item list with states and one-liners — in its projected zone; the substance lives in `items/<id>/`. A stub box is still just a README; `items/` appears on the first non-stub item, `follow-ups/` on the first park. Same static-top + projected-zone discipline as before, now projecting over folders.

**Schema stamp.** Every box README carries `box_schema: 1.3` in its frontmatter — the durable drift-control anchor (see Conventions below for the full rule).

**Location:** `.context/stuart/boxes/<slug>/` in the current project (parallel to triage's `investigations/`). Assume `.context/` exists; **ask or refuse** if it genuinely doesn't. "Homeless" never means *outside a repo* — it means *in a repo with `.context/`, but the session started without a box open*.

## Subcommand vocabulary

| Verb | Purpose | Produces | Protocol |
|---|---|---|---|
| `new <slug> [--pr REF \| --issue REF]` | Open a box. Backfill origin from the live session, **or** seed from a PR/issue. Scaffold README (+ first Log entry). | box tree | `protocols/new.md` |
| `open [path]` | Resume an existing box: resolve the box root (explicit path, or most-recently-modified box), load vocabulary, read the README head, flag any handoffs, and orient. The explicit front door for picking a box back up across sessions. | conversation only | `protocols/open.md` |
| `status` | Read-only orientation — re-orients when the box is already open. Prints the README head: state, next moves, open follow-ups, open questions. No edits. | conversation only | `protocols/status.md` |
| `plan` | **Arg-dependent.** Bare/steer = manage the **track**: add/reorder items, set states, record the items a decomposition produced; `plan next` surfaces the next `ready` item (orientation only). With an item id, `plan <id>` = compose/refine `items/<id>/plan.md` — the `needs-discovery → ready` transition. Box-native composition; **no plan mode**. Offers three doors: action now / write into the box / just discuss. | track edit in README, or `items/<id>/plan.md` | `protocols/plan.md` |
| `spec <id>` | Compose/refine `items/<id>/spec.md` — the `needs-discovery` work. What/why and the load-bearing architectural how; **open questions allowed** and recorded as `[NEEDS CLARIFICATION]` markers; dispatches fresh research agents per area. Box-native; no plan mode. Also the natural vehicle for the decomposition item. | `items/<id>/spec.md` | `protocols/spec.md` |
| `do <id>` | Resourceful **executor** — the harness layer. Reads spec **and** plan, gauges the work (size, file-disjointness, risk, the plan's explicit per-phase deps + `[P]` markers), and chooses an approach (single agent / fan-out / dynamic workflow / a per-box `workflow.js`). Runs only on an explicit go. Output is box-type-dependent: a review writes findings/draft *into* the box; a build writes code to the *real repo*. Logs the outcome to `log/` and offers done/rollup. | execution + `log/` event (+ box-type output) | `protocols/do.md` |
| `migrate [path]` | Bring an existing box up to the current schema (`box_schema: 1.3`): split `follow-ups.md` → `follow-ups/`, hoist the plan into `items/<id>/`, normalise structure, re-stamp the schema. Structural only, idempotent, never renumbers. | updated box tree + `box_schema` stamp | `protocols/migrate.md` |
| `park <text>` | **The headline gesture.** Capture a follow-up with a disposition; if it's a future-session thing, offer the carry-forward prompt. | `follow-ups/F<id>.md` (+ optional handoff) | `protocols/park.md` |
| `note <text>` | Log a decision / discovery / open question. Lighter than park — no disposition. | `log/` entry | `protocols/note.md` |
| `handoff [text]` | Write a standalone carry-forward prompt into `handoffs/`, with a box-aware resume protocol baked in. A first-class verb; `park` may also emit one for future-session dispositions. | `handoffs/` entry + `handoff` Log event | `protocols/handoff.md` |
| `pickup [path]` | Box-aware resume from a handoff (defaults to the latest in `handoffs/`): load vocabulary, read the handoff + README head, orient, and treat the handoff as a brief to act on. The box-flavoured pickup — unlike the standalone `/pickup`, which is box-blind. | conversation only | `protocols/pickup.md` |
| `rollup` | Regenerate the README projected zone from plan/follow-ups/log. Demote done & superseded material out of the active view. | updated README | `protocols/rollup.md` |
| `close` | End-of-box: reconcile every open follow-up, demote done work to `archive/`, record terminal state, draft the PR description. | closing Log entry + README | `protocols/close.md` |

## Routing

Parse the **first token** of the argument as the subcommand. Everything after it is optional **steer**: pass it verbatim to the dispatched agent as extra context, don't ignore it.

For each subcommand, **read the corresponding `${CLAUDE_SKILL_DIR}/protocols/<name>.md` file** and follow it. The protocol files hold the dispatch templates and step-by-step rules. Don't try to remember them from this index.

If the subcommand is unrecognised, list the vocabulary back to the user and ask.

**Conversational on top of explicit.** Stu's real invocation style is conversational: he opens a box (`box open <path>` or `box pickup <handoff>`) then describes the situation in natural language and lets the dispatcher route it. Support that — explicit verbs underneath, smart routing on top. When he describes a situation rather than naming a verb, infer the verb (a thing to park → `park`; a decision made → `note`; "where are we" → `status`; "what's next" → `plan next`; "resume / where was I / pick the box back up" → `open`; "write a handoff / carry this forward" → `handoff`; "pick up from <handoff>" → `pickup`; a thing to spec out / "understand this first" → `spec <id>`; "build it / run the plan / execute <id>" → `do <id>`; "bring this old box up to date" → `migrate`) and proceed, confirming only when genuinely ambiguous.

## Conventions across all subcommands

**Box root resolution.** Resolve once per invocation: `.context/stuart/boxes/<slug>/` relative to `pwd`. If the user pointed at a box (`box is here: <path>`), use that. If no slug context exists yet (first call wasn't `new`), use the most-recently-modified box under `.context/stuart/boxes/`, or ask if it's ambiguous.

**Schema stamp.** Every box's README frontmatter carries `box_schema: <version>` (current: `1.3`). It is the durable drift-control anchor: every review round and every `migrate` run reads it and compares like-for-like, so an old box can be told apart from a current one at a glance. A box with **no** `box_schema` field is **pre-1.0** (born before the stamp existed). `new` stamps `box_schema: 1.3` at birth; `migrate` re-stamps a straggler once it has been brought up to shape. Never hand-edit the stamp to claim a schema the box's structure doesn't actually match — run `migrate` instead.

**Vocabulary.** The core words. Do not collapse the README/Log split into "context" — they do two different jobs.

- **Box** — the container; one body of work. The folder.
- **README** — the head: always-current navigation. State, current-vs-superseded document map, next moves, open follow-ups, open questions. A **projected index** over the items, ~100 lines, always current — never the bodies themselves.
- **Item** — the unit of work; a projected unit, not a script. Each non-stub item lives at `items/<id>/` and carries a *state*, with up to two artefacts: `spec.md` (the `needs-discovery` understanding) and `plan.md` (the `ready`, agent-actionable plan). A box is for *many* items. Items are id'd `D1` for the decomposition/design head, then `1`, `2`, … for the work items it projects; the id is the folder name under `items/`.
- **Track** — the ordered list of items with their states and one-liners. Lives in the README's projected zone — the index over `items/`.
- **Follow-ups** — the parked track: each entry carries a disposition naming where it goes. One file per follow-up under `follow-ups/`.
- **Log** — append-only provenance and narrative: what happened, decisions, open questions. Can be long. In `log/`.

**Item states → artefacts.** Each item carries a state, and the state names which artefact has been written:

| State | Artefact at `items/<id>/` | Meaning |
|---|---|---|
| `stub` | — | placeholder on the track (`<TODO: spec out>`) |
| `needs-discovery` | `spec.md` | what/why/some-how; open questions allowed; the human slows down |
| `ready` | `plan.md` | agent-actionable; **zero** open questions; phased; verification criteria |
| `done` | body demoted to `archive/` at `close` | completed; folded off the active track by `rollup`, body relocated at `close` |

The **`needs-discovery → ready` transition *is* the spec → plan progression** — `spec <id>` writes the understanding, `plan <id>` writes the actionable plan, and the move from one to the other is the deliberate human slow-down. **Not every item needs both artefacts:** spec is optional when there's nothing to discover (promote `stub → ready`, skip it); the plan is what `do` runs against. There's no stored "in-progress" tag — "currently working an item" is conveyed by the live session plus any carry-forward handoff, not a state on the item.

**Follow-up dispositions.** Every park names where it goes — disposal language, not deferral. `in-scope-later` (do during this box, on the tail) / `→ issue` (becomes a GitHub issue, provenance linked back) / `→ new box` / `dropped` (explicitly killed, with a reason). At `close`, **every open follow-up reconciles to a terminal disposition** — that's the normal ending for a box, not an edge case.

**Follow-up IDs.** `F1`, `F2`, … — assigned by `park`, **never reused, never renumbered**. A dropped or spun-out follow-up keeps its ID forever. Entries live one-per-file under `follow-ups/` (e.g. `follow-ups/F1.md`), each carrying enough context to make sense in five days without re-discovery.

**Open-question IDs.** `Q1`, `Q2`, … — assigned by `note` when the type is `open-question`, **never reused, never renumbered**. A resolved question keeps its ID forever. The authoritative source for the highest `Q`-ID and the resolved set is the `log/` filenames (`…-open-question-Q<n>.md` raised, `…-question-resolved-Q<n>.md` settled) — the README projected zone is a lagging view. Resolution is **conversational, not a verb**: when Stu's text settles a question, the `Q<id>` in it is the dispatch signal and the resolution lands as a `question-resolved:Q<id>` Log event.

**Event log.** Append-only, never edited. One short file per major transition, named `YYYY-MM-DDTHH-MM-<event-type>.md`, usually 5–20 lines: timestamp, what changed, pointer to the artefact, one line of context. Only log when state Stu cares about has shifted — not every edit. **Filename rule for parameterised types:** the `:` in an event type renders as `-` in the filename (colons in filenames are a portability footgun), ID suffix retained — `question-resolved:Q3` → `…-question-resolved-Q3.md`, `followup-parked:F1` → `…-followup-parked-F1.md`. The hyphenated form is what `rollup` scans for. Event types:

- `born` — box created
- `seeded-from-pr` / `seeded-from-issue` — box seeded from a public ref
- `plan-updated` — track items added / reordered / state-changed
- `spec-written` — an item's `spec.md` authored or refined
- `plan-written` — an item's `plan.md` authored or refined (the `→ ready` transition)
- `do-ran` — an item executed; points at where the output landed
- `followup-parked:F<id>` — one event per park (or one covering several parked together)
- `note` — a logged decision / discovery / observation
- `decision` — a decision recorded
- `open-question:Q<id>` — an unresolved question raised (the `Q<id>` is assigned at creation, never reused or renumbered; stays visible in the README until settled)
- `question-resolved:Q<id>` — a previously-raised question settled (drops off the README, lives in the Log forever)
- `rolled-up` — README projected zone regenerated
- `handoff` — a carry-forward prompt written (points at the `handoffs/` file)
- `superseded:<doc>` — a document demoted to `archive/`
- `closed` — box closed, terminal state recorded

**Commit-before-edit.** Baked into every state-modifying verb (`plan`, `spec`, `do`, `migrate`, `park`, `note`, `rollup`, `close`). Before the edit, stage and commit the current state with a generic message: `box: snapshot before <verb>`; after the edit, commit `box: <verb> <slug>`. `new` is the exception — there's no prior state to snapshot, so it commits just once after scaffolding (`box: new <slug>`), giving the box birth a clean boundary in the history. No co-author lines, no skip-hooks.

**Stage and commit only the box's own paths — never the whole tree.** This is non-negotiable. The box often lives inside a repo that carries unrelated work (a workbook, a context repo a human is also editing in another session). A blanket `git add -A` will sweep that work into a `box:` commit — this has happened and corrupted another session's in-flight staging. The box always knows its own root, so scope **every** git operation to it via a `-- <pathspec>` and never use `add -A`:

```sh
BOX_ROOT="<absolute path to this box's own directory>"   # e.g. .../boxes/<slug>
git -C "$REPO" add -- "$BOX_ROOT"
git -C "$REPO" commit -m "box: <verb> <slug>" -- "$BOX_ROOT"
```

The pathspec on `commit` is the real safety net: `git commit -- <pathspec>` commits **only** matching paths regardless of what else is already staged in the index, so a concurrent session's staged work is physically untouchable. Pathspec on `add` keeps the index clean too. If the box legitimately needs to touch a file outside its own root (rare), stage that path explicitly by name — never widen back to `add -A`.

Resolve `$REPO`: **do NOT `cd` into the target**, because a command starting with `cd` can never be pre-approved — use `-C` for every call. When the box lives in a `.context/` repo (usually its own git repo, often a symlink), resolve it once: `REPO=$(readlink -f .context)` (use `greadlink -f` if `readlink -f` is unavailable; it's native on macOS 12.3+). When the box lives directly inside a workbook/repo, `$REPO` is that repo root and `$BOX_ROOT` is the box's subdirectory within it. If the target isn't a git repo, skip the commit and tell the user.

**Clean-tree skip.** Check status **scoped to the box root**: if `git -C "$REPO" status --porcelain -- "$BOX_ROOT"` is empty, skip the snapshot commit silently and proceed to the edit. Scoping the check to the box root is deliberate — unrelated changes elsewhere in the repo are none of the box's business and must not influence whether it snapshots. If there are **unrelated changes within the box root itself** (something you didn't make this session), **stop and ask** rather than committing them.

**Discovery before commitment.** Any dispatched subagent about to run something potentially long (big SQL, codebase-wide grep, large fan-out, PR/issue fetch with pagination) **must** spend ≤5 tool calls confirming the data shape exists before committing to the work. This is the stuck-agent insurance.

**Subagent dispatch shape.** When a protocol dispatches a subagent, the brief always includes: (1) the box root path, (2) which specific files to read first, (3) the named artefact path it must produce, (4) the ≤5-line return format expected, (5) the discovery-before-commitment rule. Never dispatch with "go do X" — always with the artefact path and shape. If the subagent produces anything public-facing, pass it the leak-free rule below.

**Public artefacts never leak the box.** The box is a private working tool (it lives in a private context repo; most of the code it describes is open source). Anything that leaves the box for a public surface — a GitHub issue, a PR description, an external comment — must stand on its own in plain English and **must not** carry the box's internal vocabulary: no follow-up IDs (`F1`, `F2`), no item ids, no slug references, no "the box found…", no `items/`/`follow-ups/`/`plan.md`/`spec.md` pointers. Translate into how a person would naturally write it. And per Stu's standing rule, **draft only — never post to a public surface unprompted.**

**Projected-zone markers.** The README has a hand-curated static zone and a regenerated projected zone, delimited by:

```
<!-- BOX: BEGIN PROJECTED -->
…
<!-- BOX: END PROJECTED -->
```

`rollup` only ever replaces the content **between** the markers. The static zone above is hand-curated and never touched by rollup. If the markers are missing, warn and ask before reconstructing.

## Resolved design decisions

These were open questions in the design brief; they are now locked.

1. **The track lives in the README; item bodies live in `items/<id>/`.** The README's projected zone holds the track (ordered items + states + one-liners) — the index. Substance (a `spec.md` and/or `plan.md`) lives under `items/<id>/`, created on the first non-stub item. No inline plan body in the README.
2. **Discovery is the `spec` verb.** The `needs-discovery → ready` transition is the `spec → plan` progression: `spec <id>` writes `items/<id>/spec.md` (open questions allowed); `plan <id>` writes `items/<id>/plan.md` (zero open questions). Spec is optional when there's nothing to discover.
3. **Rollup is manual only.** Source files (`plan`, `follow-ups/`, `log/`) are the truth; the projected zone is a view. No auto-trigger.
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

## Out of scope

- **A persistent agentic execution loop.** The `run.sh` / `queue.json` driver fan-out is its own beast, deferred. `do` is a resourceful per-invocation dispatcher, not that loop: it gauges one item's plan and dispatches it (a single agent, a fan-out, a dynamic `Workflow`, or a per-box `workflow.js`), then stops. It does not drain a queue unattended.
- **Cross-box / portfolio machinery.** One box, one body of work. Boxes may reference each other; nothing coordinates above them.
- **Triage migration.** Fold triage in once box has proven out.
- **The beads projection.** The box owns the whole climb; beads only ever sees the ready top rungs — and not here.
