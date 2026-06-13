---
name: box
description: Use for work that spans multiple sessions over days or weeks and needs durable on-disk state (plan, follow-ups, history) that each new session can load and continue from.
argument-hint: "new · import · open · status · plan · spec · do · migrate · park · note · handoff · pickup · rollup · close"
# Scoped git pre-approval for the commit contract. Only matters outside
# bypassPermissions/acceptEdits mode — in Stu's normal setup these are
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

A box is an on-disk folder holding the durable state for one body of work, so any fresh session can load it and continue. It starts as a single README and grows folders only as needed; the layout never changes shape. One box = one contained body of work.

The main session is a dispatcher with a fixed verb set. Each subcommand reads its `protocols/<name>.md` and produces a named artefact in a predictable place. History is append-only. The README is a thin, always-current index — not the substance. Most verbs run inline; `spec`, `do`, and `import` may dispatch subagents, and the dispatch-shape rules below govern every fork.

A box does five jobs, in priority order:

1. **Drive the work** — hold an ordered track of items, each carrying a state.
2. **Capture cheaply** — when something surfaces mid-flow, park it with a decision about where it goes.
3. **Keep the active view small** — move done and superseded work out of view while preserving it; keep open questions visible.
4. **Preserve history** — how the work came to be and what was decided along the way.
5. **Bootstrap the next session** — opening the box is the context load.

## When to use

- A body of work that spans days or weeks and several sessions.
- Taking over someone else's in-flight work (seed a box from a PR or issue).
- A session in a repo with `.context/` that has grown into something worth keeping.

## When NOT to use

- A task you finish in one session — just do it.
- A production bug investigation — use `triage`.
- A meeting note or write-up — use the workbook.
- Coordinating across many bodies of work — out of scope. One box, one body of work.

## A box is for many items

A box exists because the work is big. The items, plural, *are* the work. If a box reduces to one item → one spec → one plan, it never needed to be a box — that is just a task. So do not create a single all-encompassing item and run it through spec → plan → do.

The opening move is to orient and decompose. The cleanest model: decomposition/design is itself the opening item — the head item (`D1`) whose job is to understand the shape of the work and list the other items. Those items then move, individually, through `spec` → `plan` → `do`. When a box opens around something large, `new` and `plan` prompt to cut it up rather than recording one big item.

## Working layout

A new box is just `README.md`. Folders are created on demand, on first use; the structure is never reorganised.

```
<slug>/
├── README.md          # static top + projected index (track, open follow-ups, open questions). Frontmatter: box_schema: 1.3
├── items/             # item bodies — created on the first non-stub item
│   └── <id>/
│       ├── spec.md    #   written at needs-discovery — what/why; open questions allowed
│       └── plan.md    #   written at ready — agent-actionable; zero open questions; phased
├── follow-ups/        # one file per parked follow-up (F<n>.md) — created on first park
├── log/               # append-only events + decisions — exists from creation (`new` writes the first event)
├── handoffs/          # carry-forward prompts — created on the first handoff
└── archive/           # done/superseded items + docs, each superseded doc carrying a SUPERSEDED banner
```

The README keeps the **track** — the ordered item list with states and one-liners — in its projected zone; the substance lives in `items/<id>/`. The README indexes the items; it never contains their bodies.

**Location:** `.context/stuart/boxes/<slug>/` in the current project (parallel to triage's `investigations/`). Assume `.context/` exists; ask or refuse if it genuinely doesn't. "Homeless" means a session in a repo that has `.context/` but where no box was opened — it never means outside a repo.

## Subcommand vocabulary

| Verb | Purpose | Produces | Protocol |
|---|---|---|---|
| `new <slug> [--pr REF \| --issue REF]` | Create a box, from the live session or seeded from a PR/issue. | box tree | `protocols/new.md` |
| `import [<slug>] [--corpus PATH]` | Bring pre-existing work into a new box without breaking invariants. | box tree | `protocols/import.md` |
| `open [path]` | Resume an existing box across sessions — the front door. | conversation only | `protocols/open.md` |
| `status` | Read-only state report when the box is already open. | conversation only | `protocols/status.md` |
| `plan` | Bare/steer: manage the track. `plan <id>`: write `items/<id>/plan.md`. | track edit, or `items/<id>/plan.md` | `protocols/plan.md` |
| `spec <id>` | Write or refine `items/<id>/spec.md`; open questions allowed. | `items/<id>/spec.md` | `protocols/spec.md` |
| `do <id>` | Execute one ready item, on an explicit go from Stu. | execution + `log/` event | `protocols/do.md` |
| `migrate [path]` | Bring an older box up to the current schema. | updated box tree | `protocols/migrate.md` |
| `park <text>` | Capture a follow-up with a disposition; may also write a handoff. | `follow-ups/F<id>.md` | `protocols/park.md` |
| `note <text>` | Log a decision, discovery, or open question. | `log/` entry | `protocols/note.md` |
| `handoff [text]` | Write a carry-forward prompt into `handoffs/`. | `handoffs/` entry + log event | `protocols/handoff.md` |
| `pickup [path]` | Resume from a handoff (default: the latest) and act on it. | conversation only | `protocols/pickup.md` |
| `rollup` | Regenerate the README projected zone from the source files. | updated README | `protocols/rollup.md` |
| `close` | End the box: reconcile follow-ups, archive done work, draft the PR description. | closing log entry + README | `protocols/close.md` |

## Routing

Parse the **first token** of the argument as the subcommand. Everything after it is optional **steer**: pass it verbatim into the work, don't ignore it.

For each subcommand, **read the corresponding `${CLAUDE_SKILL_DIR}/protocols/<name>.md` file** and follow it. The protocol files hold the dispatch templates and step-by-step rules. Don't try to remember them from this index.

If the subcommand is unrecognised, list the vocabulary back to the user and ask.

**Conversational on top of explicit.** Stu's real invocation style is conversational: he opens a box then describes the situation in natural language. When he describes a situation rather than naming a verb, infer it (a thing to park → `park`; a decision made → `note`; "where are we" → `status`; "what's next" → `plan next`; "resume" → `open`; "understand this first" → `spec <id>`; "build it" → `do <id>`; "write a handoff / carry this forward" → `handoff`; "pick up from <handoff>" → `pickup`; "bring this old box up to date" → `migrate`) and proceed, confirming only when genuinely ambiguous.

## Conventions

Shared rules, stated once. Protocols point here rather than restating them.

**Box root resolution.** Resolve once per invocation: `.context/stuart/boxes/<slug>/` relative to `pwd`. If the user pointed at a box (`box is here: <path>`), use that. If no slug context exists yet, use the most-recently-modified box under `.context/stuart/boxes/`, or ask if it's ambiguous.

**Schema stamp.** Every box README carries `box_schema: <version>` (current: `1.3`) in its frontmatter. A README with no `box_schema` field is pre-1.0. `new` stamps it at creation; `migrate` re-stamps once a box has been brought up to shape. Never hand-edit the stamp — run `migrate` instead.

**Vocabulary.** The structure names. Don't collapse the README/Log split into "context" — they do two different jobs.

- **Box** — the container; one body of work. The folder.
- **README** — the box's head: always-current navigation — state, document map, next moves, open follow-ups, open questions. An index over the items, ~100 lines — never the bodies themselves.
- **Item** — the unit of work. Each non-stub item lives at `items/<id>/` with up to two artefacts: `spec.md` (the understanding) and `plan.md` (the agent-actionable plan). IDs: `D1` for the decomposition head, then `1`, `2`, … for work items; the ID is the folder name under `items/`.
- **Track** — the ordered list of items with their states and one-liners. Lives in the README's projected zone.
- **Follow-up** — a parked piece of future work, one file per entry under `follow-ups/`, each carrying a disposition.
- **Disposition** — the recorded decision about where a follow-up goes: `in-scope-later` (do during this box, towards the end) / `→ issue` (file a tracker issue, linked back to its origin) / `→ new box` / `dropped`.
- **Log** — append-only history: what happened, decisions, open questions. Can be long. In `log/`.
- **Projected zone** — the README section between markers that `rollup` regenerates from the source files; the hand-written static zone sits above it.
- **Readiness checklist** — the checklist at the foot of a spec that must be fully ticked before the item may be set to `ready`.

**Item states.** Each item carries a state; the state names which artefact has been written:

| State | Artefact at `items/<id>/` | Meaning |
|---|---|---|
| `stub` | — | placeholder on the track |
| `needs-discovery` | `spec.md` | what/why; open questions allowed; the deliberate pause for understanding |
| `ready` | `plan.md` | agent-actionable; **zero** open questions; phased; verification criteria |
| `done` | body moved to `archive/` at `close` | completed; dropped from the active track by `rollup` |
| `superseded` | body moved to `archive/` at `close` | closed without being built — its scope was absorbed or replaced by other items |

The `needs-discovery → ready` move is the spec → plan progression: `spec <id>` writes the understanding, `plan <id>` writes the actionable plan. **A spec is optional** — when there's nothing to discover, set the item straight from `stub` to `ready` and write the plan; a review item may be spec-heavy with a thin plan, a mechanical item plan-only. There is no stored "in-progress" state — "currently working an item" is carried by the live session plus any handoff.

**IDs are permanent.** Follow-up IDs (`F1`, `F2`, …, assigned by `park`) and open-question IDs (`Q1`, `Q2`, …, assigned by `note`) are never reused and never renumbered; a dropped follow-up or resolved question keeps its ID forever. Next-ID authority: for `F`, the `follow-ups/F*.md` listing; for `Q`, the `log/` filenames — the README is a lagging view. Question resolution is conversational, not a verb: when Stu's text settles a question, write a `question-resolved:Q<id>` log event.

**Event log.** Append-only, never edited. One short file per major transition, named `YYYY-MM-DDTHH-MM-<event-type>.md`, usually 5–20 lines. Only log when state Stu cares about has shifted — not every edit. Filename rule: a `:` in a parameterised event type becomes `-` in the filename, ID suffix retained (`question-resolved:Q3` → `…-question-resolved-Q3.md`). The full event-type list lives in `protocols/rollup.md`; each writing protocol names the events it emits.

**Commit contract (commit-before-edit).** Every state-modifying verb (`plan`, `spec`, `do`, `migrate`, `park`, `note`, `handoff`, `rollup`, `close`) commits the current state before editing — `box: snapshot before <verb>` — and commits again after — `box: <verb> <slug>`. `new` is the exception: nothing exists beforehand, so it commits once after scaffolding (`box: new <slug>`). `import` additionally commits per phase as its protocol specifies. No co-author lines, no skip-hooks.

Stage and commit **only the box's own paths — never the whole tree**. The box often lives in a repo carrying unrelated work, and a blanket `git add -A` has previously swept another session's in-flight changes into a `box:` commit. Scope every git operation via pathspec and never use `add -A`:

```sh
BOX_ROOT="<absolute path to this box's own directory>"
git -C "$REPO" add -- "$BOX_ROOT"
git -C "$REPO" commit -m "box: <verb> <slug>" -- "$BOX_ROOT"
```

The pathspec on `commit` is the real safety net: `git commit -- <pathspec>` commits only matching paths regardless of what else is staged. If the box legitimately needs to touch a file outside its root (rare), stage that path explicitly by name.

Resolve `$REPO` without `cd` (a command starting with `cd` can never be pre-approved — use `-C` everywhere). For a box in a `.context/` repo (often a symlink): `REPO=$(readlink -f .context)` (`greadlink -f` if needed); for a box directly inside a workbook/repo, `$REPO` is that repo root and `$BOX_ROOT` the box's subdirectory. If the target isn't a git repo, skip the commit and tell the user.

**Clean-tree skip.** If `git -C "$REPO" status --porcelain -- "$BOX_ROOT"` is empty, skip the snapshot commit silently. The check is scoped to the box root deliberately — unrelated changes elsewhere in the repo are not the box's business. If there are unrelated changes *within* the box root (something you didn't make this session), stop and ask rather than committing them.

**Discovery before commitment.** Any dispatched subagent about to run something potentially long (big SQL, codebase-wide grep, large fan-out, paginated PR/issue fetch) must spend ≤5 tool calls confirming the data shape exists before committing to the work.

**Subagent dispatch shape.** Every subagent brief includes: (1) the box root path, (2) which files to read first, (3) the named artefact path it must produce, (4) the ≤5-line return format expected, (5) the discovery-before-commitment rule. Never dispatch "go do X". If the subagent produces anything public-facing, pass it the leak rule below.

**Public artefacts never leak the box.** The box is a private working tool; most of the code it describes is open source. Anything that leaves the box for a public surface — a GitHub issue, a PR description, an external comment — must stand on its own in plain English with none of the box's internal vocabulary: no `F<id>`/`Q<id>`, no item IDs, no slug, no "the box found…", no `items/`/`follow-ups/` pointers. Write it the way a person would. And per Stu's standing rule, **draft only — never post to a public surface unprompted.**

**Projected-zone markers.** The README's projected zone is delimited by:

```
<!-- BOX: BEGIN PROJECTED -->
…
<!-- BOX: END PROJECTED -->
```

`rollup` only ever replaces the content between the markers; the static zone above is hand-written and never touched. If the markers are missing, warn and ask before reconstructing.

**Plan vs execute, and the three doors.** Composing verbs (`new`, `import`, `spec`, `plan`) stop at the artefact; `do` is the only verb that executes, and only on an explicit go from Stu. Stu typically composes in one session and executes in another — never roll from composition into execution. After composing or proposing, offer three doors and wait:

1. **Action it now** — "Want me to run / dispatch this?"
2. **Write it into the box** — commit the artefact and stop.
3. **Discuss** — iterate before writing anything in.

A trailing steer is context, not consent — it is never a go.

**Box-native composition.** `spec` and `plan` compose documents inside the box. Never use Claude Code's native plan mode or `ExitPlanMode` for them — those control *code* execution and are the wrong mechanism for writing a document.

## Style

- British English in scaffolded files. No emoji. Short, complete sentences.
- File templates use Markdown; YAML frontmatter only where a field is used by the machinery (e.g. `superseded_by:` on archived docs).
- No back-references in artefacts ("as discussed earlier") — every artefact stands alone or links explicitly.
- **Skill vocabulary stays in the files.** Terms like "disposition", "track", "projected zone" are internal structure — fine in artefacts, not in conversation. When talking to Stu, say the plain thing: "F1 depends on this question", not "this question gates F1". Conversational output is plain spoken English, optimised for first-read comprehension.

## Out of scope

- **A persistent agentic execution loop.** `do` handles one item per invocation and then stops; it does not drain a queue unattended.
- **Cross-box coordination.** One box, one body of work. Boxes may reference each other; nothing coordinates above them.
- **Triage migration.** Fold triage in once box has proven out.
- **Beads integration** is out of scope for this skill.
