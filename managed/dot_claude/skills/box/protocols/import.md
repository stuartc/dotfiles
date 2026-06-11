# Protocol: import

Bring a body of work that **predates the box** into a box without breaking any of the box's invariants. The corpus already exists — scattered docs, plan material, findings, git history, a memory file, maybe a half-remembered session — and the job is to land it as a well-formed box, not to dump it.

`import` is **not a single verb** — it is a procedure that composes the existing vocabulary (`new → plan → note → park → rollup`, plus `archive` demotion). There is no shortcut that bypasses the verbs; every shortcut breaks the source-of-truth, ID, or projected-zone contract. Like `new`, `import` produces an artefact and **stops** — it does not roll into executing the work.

`import` composes existing verbs rather than introducing new state — it has no dedicated automation beyond this procedure. Invoke it as `box import …` or in plain language ("import this context into a box"); both route here.

## Args

`import [<slug>] [--corpus <path-or-glob>]`

- `<slug>` — kebab-case, descriptive, as for `new`. If omitted, propose one from the corpus and confirm.
- `--corpus <path>` — where the pre-existing context lives (a `.context` subtree, a docs folder). If omitted, infer from the live session and the project's `.context/`.

## The two ideas that make import safe

**1. Replay, not dump.** Write into the *source* files (the track, `items/<id>/`, `follow-ups/`, `log/`) and let `rollup` generate the head. Never hand-author the projected zone — the next rollup overwrites it. The corpus is re-expressed *through the verbs*, one role at a time.

**2. A box born mature.** A normal box starts as one README and accretes structure on demand. An import is the **one sanctioned exception** to "accrete on demand": you arrive holding enough material to justify `items/`, `follow-ups/`, `log/`, and `archive/` from the first commit. Create exactly the structure the material demands — no more. Every *other* invariant (append-only log, ID discipline, derived projected zone, commit boundaries, the leak rule, the `box_schema` stamp) holds exactly as normal.

## Steps

### 1. Inventory the corpus (discovery)

Before writing anything, classify every existing artefact by the **role it will play in the box**. For a large corpus, dispatch a read-only discovery agent per the subagent-dispatch shape (box root path, files to read first, named return, ≤5-line return format, discovery-before-commitment rule). Bucket each piece:

- **Provenance / origin** — how the work came to be → seeds `## Origin` and the `born` event.
- **Plan material** — ordered intent, phases, next steps → becomes the **track and its items**. Mark each `done` vs open.
- **Findings / decisions** — settled conclusions → `note` / `decision` Log events.
- **Open questions** — unresolved → `Q`-ids.
- **Follow-ups** — parked future work → `F`-ids with dispositions.
- **Reference / background** — context but not active work → linked by path in the Document map; not ingested.
- **Superseded / dead** — replaced or stale → `archive/` with a death-banner.

Flag duplication and overlap explicitly (parallel doc trees, `-review` variants, a memory digest that mirrors the docs). The inventory is the plan for the rest of the import; surface it for approval before materialising anything.

**Reconcile stale state first.** A pre-box corpus often disagrees with reality — a memory note says "uncommitted on branch X" while `main` already has the work; a doc names an old version. Run `git log`/`git status` and check the live tree, and resolve contradictions **before** writing the box's status line. The box must describe what is true now, not what was true when the last doc was written.

### 2. Seed the box — `new` (born-from-session)

Run the `new` protocol, no seed flag (the corpus is in the session, not a PR/issue). It stamps `box_schema: 1.3` in the README frontmatter — an imported box carries the same stamp as any other. Fill the static zone:

- **`## The prize`** — the intent and definition of done, distilled from the provenance bucket.
- **`## Repo facts`** — repo, branch, key paths, build/test commands; the *reconciled* current facts.
- **`## Origin`** — why the work exists and how it grew. Provenance, not status.
- **`## Track`** — seed one or two lines only; the full track lands in step 3.

Commit once: `box: new <slug>`. The box is born as `README.md` + the `born` log event.

### 3. Lay the track and items — `plan`

This is where v1.3's item model does the work. An import legitimately arrives able to project **many items** — that's the box's "orient and decompose" opening move, except the corpus has already done the orienting. Collapse the plan material into **one ordered track**: sequential chapters (a "phase 1 plan" tree and a "phase 2 plan" tree) are not duplicates — they concatenate into one track, not two boxes.

For each track item:

- **State honestly.** Completed work → `` `[done]` `` (checkbox ticked). Open work → `` `[ready]` `` if its plan material is agent-actionable with zero open questions, `` `[needs-discovery]` `` if understanding is still the risk, `` `[stub]` `` if it's only a named intent.
- **Give substance a folder.** Each item whose corpus material earns it gets `items/<id>/`. Actionable phased material lands as `plan.md`; understanding-stage material with open questions lands as `spec.md` (record the unknowns as inline `[NEEDS CLARIFICATION]` markers). **Not every item needs both** — a mechanical item is plan-only; a research-heavy item may be spec-only for now. A `done` item keeps its body at `items/<id>/` (close performs the terminal demotion later); a `done` item with no substance worth keeping is just a ticked track line.
- **The track line is the index, not the body.** One line per item per `templates/plan-item.md` (`` - [ ] <id> · <one-liner>  `[state]` ``); the substance lives under `items/<id>/`. Never paste plan bodies into the README.

Log one `plan-updated` event for the lay-down, plus `spec-written` / `plan-written` events for item artefacts materialised from the corpus (backdated per step 4 if they record past authorship).

### 4. Replay findings & decisions — `note`

Each settled finding or decision becomes an append-only Log event (`note` or `decision`). Keep distinct findings **distinct** — a measured-results doc, a research-synthesis doc, and a build-verdict doc are three notes, not one merged note; they play different roles.

**Backdate the filenames.** A backported event describes a past transition, so name its file with the work's *actual* date (`2026-06-07T…`), not today. `rollup` sorts log filenames to reconstruct chronology and read the latest N — honest dates preserve the real timeline. The `born` event from step 2 is the only "today" event.

### 5. Assign Q-ids and F-ids — `note` (open-question) and `park`

Open questions → `Q1, Q2, …`; follow-ups → `F1, F2, …`. Assign **contiguously** from the right authority: F from the `follow-ups/F*.md` listing, Q from the `log/` filename scan (both `…-open-question-Q<n>.md` and `…-question-resolved-Q<n>.md`). Compute max+1; never reset to 1, never collide, never renumber. Remember the colon→hyphen filename rule (`open-question:Q1` → `…-open-question-Q1.md`).

Each follow-up is its own file `follow-ups/F<id>.md` per the `park` protocol's grain — there is no aggregate follow-ups file. Every one carries a disposition (`in-scope-later` / `→ issue` / `→ new box` / `dropped`) and enough context to stand alone in five days.

### 6. Reference vs archive

- **Reference / background** docs stay where they are and are **named by path** in the Document map. Do not copy their content into the box — link to it. Note version-staleness inline ("v0.8.1-era; the spike runs 0.10").
- **Superseded / dead** docs move to `archive/` with the death-banner at the top of the body (`**SUPERSEDED (<date>) — see <X>. Do not act on this.**`) and a `superseded_by: <X>` frontmatter field. Log one `superseded:<doc>` event per demotion. If a superseded doc lives in the wider `.context` outside the box, demoting it means moving it under the box's `archive/` (or banner-marking in place and linking) — decide per case and record which.
- **Never demote an undecided question.** Archival is for the done and the superseded; an open question stays visible.

### 7. Project the head — `rollup`

A single `rollup` composes the projected zone (between the `<!-- BOX: BEGIN PROJECTED -->` / `<!-- BOX: END PROJECTED -->` markers) from everything seeded in steps 3–6: State, Document map, Next moves, Open follow-ups, Open questions. This is the **only** step that writes the projected zone. Confirm the counts match the inventory (N track items, M open follow-ups, K open questions).

### 8. Commit boundaries

`new` commits once. Thereafter, commit **per logical phase** (one snapshot+commit around the track/items lay-down, one around the findings replay, one around the rollup) — not per micro-edit, not one giant commit. Scope every git call to the box's own root via pathspec (`git -C "$REPO" add -- "$BOX_ROOT"`, `git -C "$REPO" commit -m … -- "$BOX_ROOT"`) — **never `add -A`**, per the contract; never `cd`. Clean-tree skip uses the box-scoped status check (`git -C "$REPO" status --porcelain -- "$BOX_ROOT"`). If there are **unrelated** changes within the box root, stop and ask.

### 9. Report and stop

One paragraph: path scaffolded, what landed where (track items and their states, item folders created, Q-ids, F-ids, archived docs), and the reconciliations made. Suggested next step is usually `box status` or `box handoff`. **Do not begin the work** — `import`, like `new`, stops at the artefact.

## Invariants checklist (what a naive dump breaks)

- **Never hand-write the projected zone** — it is derived; only `park`/`note`'s narrow live-adds touch it outside `rollup`.
- **Track is index, items are substance** — no plan bodies in the README; each item's body lives at `items/<id>/` (`spec.md` and/or `plan.md`), never inline.
- **IDs are forever** — compute max+1 from the right authority (`follow-ups/` for F, `log/` filenames for Q), assign contiguously, never reuse or renumber. Dropped/spun-out items keep their ID.
- **Log is append-only** — a backported event is frozen once written; corrections are new events, backdated honestly.
- **Born-mature is the only accretion exception** — create the structure the material demands, nothing speculative.
- **Keep distinct findings distinct; don't collapse README/Log** — navigation and narrative do different jobs.
- **Death-banner discipline** — no demotion to `archive/` without banner + `superseded_by:` + `superseded:<doc>` event; never demote an *undecided* question.
- **Public artefacts never leak box vocab** — drafted issues/PRs carry no `F<id>`, item ids, slug, or box pointers; draft only, never post unprompted.
- **No back-references** — every artefact stands alone or links by explicit path; "as discussed earlier" is banned.

## Discovery rule

The step-1 inventory agent confirms the corpus shape in ≤5 calls before committing to deep reads — don't read a 3 MB transcript or paginate full git history into context. Characterise large artefacts (size, role, current-vs-superseded) and read deeply only what a role assignment genuinely needs.
