# Protocol: import

Bring a body of work that predates the box into a box without breaking any of the box's invariants. The corpus already exists — scattered docs, plan material, findings, git history, a memory file — and the job is to land it as a well-formed box, not to dump it.

`import` is a procedure that composes the existing vocabulary (`new → plan → note → park → rollup`, plus archiving) rather than a single verb with its own machinery. There is no shortcut that bypasses the verbs; every shortcut breaks the source-of-truth, ID, or projected-zone rules. Like `new`, `import` produces an artefact and **stops** — it does not roll into executing the work.

Invoke it as `box import …` or in plain language ("import this context into a box"); both route here.

## Args

`import [<slug>] [--corpus <path-or-glob>]`

- `<slug>` — kebab-case, descriptive, as for `new`. If omitted, propose one from the corpus and confirm.
- `--corpus <path>` — where the pre-existing context lives (a `.context` subtree, a docs folder). If omitted, infer from the live session and the project's `.context/`.

## The two ideas that make import safe

**1. Replay, not dump.** Write into the *source* files (the track, `items/<id>/`, `follow-ups/`, `log/`) and let `rollup` generate the head. Never hand-write the projected zone — the next rollup overwrites it. The corpus is re-expressed through the verbs, one role at a time.

**2. A box created mature.** A normal box starts as one README and grows folders on first use. An import is the one sanctioned exception: you arrive holding enough material to justify `items/`, `follow-ups/`, `log/`, and `archive/` from the first commit. Create exactly the structure the material demands — no more. Every other invariant (append-only log, ID rules, derived projected zone, commit boundaries, the public-leak rule, the `box_schema` stamp) holds exactly as normal.

## Steps

### 1. Inventory the corpus (discovery)

Before writing anything, classify every existing artefact by the role it will play in the box. For a large corpus, dispatch a read-only discovery agent per the subagent dispatch shape in SKILL.md. Bucket each piece:

- **Origin** — how the work came to be → seeds `## Origin` and the `born` event.
- **Plan material** — ordered intent, phases, next steps → becomes the track and its items. Mark each `done` vs open.
- **Findings / decisions** — settled conclusions → `note` / `decision` log events.
- **Open questions** — unresolved → `Q`-IDs.
- **Follow-ups** — parked future work → `F`-IDs with dispositions.
- **Reference / background** — context but not active work → linked by path in the Document map; not ingested.
- **Superseded / dead** — replaced or stale → `archive/` with a SUPERSEDED banner.

Flag duplication and overlap explicitly (parallel doc trees, `-review` variants, a memory digest that mirrors the docs). The inventory is the plan for the rest of the import; surface it for approval before writing anything.

**Reconcile stale state first.** A pre-box corpus often disagrees with reality — a memory note says "uncommitted on branch X" while `main` already has the work; a doc names an old version. Run `git log`/`git status` and check the live tree, and resolve contradictions **before** writing the box's status line. The box must describe what is true now, not what was true when the last doc was written.

### 2. Seed the box — `new`

Run the `new` protocol, no seed flag (the corpus is in the session, not a PR/issue). It stamps `box_schema: 1.3` as usual. Fill the static zone:

- **`## The prize`** — the intent and definition of done, distilled from the origin bucket.
- **`## Repo facts`** — repo, branch, key paths, build/test commands; the *reconciled* current facts.
- **`## Origin`** — why the work exists and how it grew. History, not status.
- **`## Track`** — seed one or two lines only; the full track lands in step 3.

Commit once: `box: new <slug>`.

### 3. Lay the track and items — `plan`

An import legitimately arrives able to list many items — the corpus has already done the orienting that the decomposition head would normally do. Collapse the plan material into **one ordered track**: sequential chapters (a "phase 1 plan" tree and a "phase 2 plan" tree) are not duplicates — they concatenate into one track, not two boxes.

For each track item:

- **Set the state to match reality.** Completed work → `` `[done]` `` (checkbox ticked). Open work → `` `[ready]` `` if its plan material is agent-actionable with zero open questions, `` `[needs-discovery]` `` if understanding is still the risk, `` `[stub]` `` if it's only a named intent.
- **Give substance a folder.** Each item whose corpus material warrants it gets `items/<id>/`. Actionable phased material lands as `plan.md`; understanding-stage material with open questions lands as `spec.md` (record the unknowns as inline `[NEEDS CLARIFICATION]` markers). Per SKILL.md, not every item needs both. A `done` item keeps its body at `items/<id>/` (`close` moves it later); a `done` item with no substance worth keeping is just a ticked track line.
- **The track line is the index, not the body.** One line per item per `templates/plan-item.md`; the substance lives under `items/<id>/`. Never paste plan bodies into the README.

Log one `plan-updated` event for the lay-down, plus `spec-written` / `plan-written` events for item artefacts materialised from the corpus (backdated per step 4 if they record past authorship).

### 4. Replay findings and decisions — `note`

Each settled finding or decision becomes an append-only log event (`note` or `decision`). Keep distinct findings **distinct** — a measured-results doc, a research-synthesis doc, and a build-verdict doc are three notes, not one merged note.

**Backdate the filenames.** A backported event describes a past transition, so name its file with the work's *actual* date, not today — `rollup` sorts log filenames to reconstruct chronology, so accurate dates preserve the real timeline. The `born` event from step 2 is the only "today" event.

### 5. Assign Q-IDs and F-IDs — `note` and `park`

Per the ID rules in SKILL.md: assign contiguously from the right authority (F from the `follow-ups/F*.md` listing, Q from the `log/` filename scan), compute max + 1, never reset, collide, or renumber. Remember the colon→hyphen filename rule.

Each follow-up is its own file `follow-ups/F<id>.md` per the `park` protocol. Every one carries a disposition and enough context to stand alone in five days.

### 6. Reference vs archive

- **Reference / background** docs stay where they are and are named by path in the Document map. Don't copy their content into the box — link to it. Note version staleness inline ("v0.8.1-era; the spike runs 0.10").
- **Superseded / dead** docs move to `archive/` with the SUPERSEDED banner at the top of the body and a `superseded_by: <X>` frontmatter field. Log one `superseded:<doc>` event per move. If a superseded doc lives in the wider `.context` outside the box, either move it under the box's `archive/` or banner-mark it in place and link — decide per case and record which.
- **Never archive an undecided question.** Archiving is for the done and the superseded; an open question stays visible.

### 7. Generate the head — `rollup`

A single `rollup` composes the projected zone from everything seeded in steps 3–6: State, Document map, Next moves, Open follow-ups, Open questions. This is the **only** step that writes the projected zone. Confirm the counts match the inventory (N track items, M open follow-ups, K open questions).

### 8. Commit boundaries

`new` commits once. Thereafter, commit per logical phase (one snapshot+commit around the track/items lay-down, one around the findings replay, one around the rollup) — not per micro-edit, not one giant commit. Pathspec scoping per the commit contract in SKILL.md; never `add -A`, never `cd`. If there are unrelated changes within the box root, stop and ask.

### 9. Report and stop

One paragraph: path scaffolded, what landed where (track items and their states, item folders created, Q-IDs, F-IDs, archived docs), and the reconciliations made. Suggested next step is usually `box status` or `box handoff`. **Do not begin the work.**

## Invariants checklist (what a naive dump breaks)

- **Never hand-write the projected zone** — it is derived; only `park`/`note`'s narrow live-adds touch it outside `rollup`.
- **Track is index, items are substance** — no plan bodies in the README.
- **IDs are permanent** — per SKILL.md; gaps are correct, not a bug.
- **Log is append-only** — a backported event is frozen once written; corrections are new events, dated accurately.
- **Created-mature is the only exception to grow-on-demand** — create the structure the material demands, nothing speculative.
- **Keep distinct findings distinct; don't collapse README/Log** — navigation and narrative do different jobs.
- **SUPERSEDED banner discipline** — no move to `archive/` without banner + `superseded_by:` + `superseded:<doc>` event; never archive an undecided question.
- **Public artefacts never leak box vocabulary** — per SKILL.md; draft only, never post unprompted.
- **No back-references** — every artefact stands alone or links by explicit path.

## Discovery rule

The step-1 inventory agent confirms the corpus shape in ≤5 calls before committing to deep reads — don't read a 3 MB transcript or paginate full git history into context. Characterise large artefacts (size, role, current vs superseded) and read deeply only what a role assignment genuinely needs.
