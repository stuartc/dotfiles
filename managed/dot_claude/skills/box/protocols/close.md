# Protocol: close

End the box. Reconcile every open follow-up to a terminal disposition, demote done work to `archive/`, record a terminal state in the README static zone, and draft (never post) the PR description. For a box, this is the **normal ending** — the ~70% tail-end workflow, not an edge case. The core value is forcing every parked follow-up to a terminal fate so nothing rots.

`close` ends the box; it does not start new work. Where reconciliation points a follow-up at a new box or a GitHub issue, `close` *records the routing and drafts the artefact* — it does not execute the spun-out work.

## Args

`close [terminal-state]`

- `[terminal-state]` — optional, one of: `done` / `spun-out` / `abandoned` / `superseded-by <slug>`. If omitted, infer from the box state (all items done → `done`; everything reconciled to issues/new boxes with no items shipped → `spun-out`; abandoned mid-flight → `abandoned`) and confirm in one line before recording.

## Steps

### 1. Resolve

Resolve the box root per the contract's box-root resolution rule. If it's genuinely ambiguous, ask — closing the wrong box is expensive.

### 2. Refresh the view first

Run `box rollup` (or its equivalent) before closing, so the projected zone reflects reality — plan states, demotions, open follow-ups, open questions — before you reconcile against it. Don't re-specify rollup's internals here; call it by name and let it regenerate the projected zone between the `<!-- BOX: BEGIN PROJECTED -->` / `<!-- BOX: END PROJECTED -->` markers. If the markers are missing, warn and ask before proceeding — don't reconstruct.

Closing against a stale head is how a follow-up gets missed. The refresh is not optional.

### 2a. Snapshot first (commit-before-edit)

Steps 3–5 all edit the box, so snapshot the pre-close state **before** any of them per the contract's commit-before-edit rule (`box: snapshot before close`) — matching the up-front snapshot every other write-verb takes.

### 3. Reconcile every open follow-up

The real work of `close`. Read each `follow-ups/F<id>.md`. For **each** open `F<id>` (anything not already at a terminal disposition), force a terminal fate — nothing stays merely `in-scope-later` or parked. Update each entry's disposition tag in place (the `[{{DISPOSITION}}]` in its heading) so the file itself records the outcome; the Log records the reconciliation summary.

For each open follow-up, route it to one of:

- **`→ issue`** — record the GitHub issue URL on the entry. If the issue isn't drafted yet, draft it now — leak-free (plain English, none of the box's internal vocabulary: no `F<id>`, no slug, no `plan.md`/`follow-ups/` pointers), **draft only, never post** (per Stu's standing rule). Show Stu the draft; he sends it. Record the URL once it exists; if it doesn't exist yet, record "issue draft ready — pending Stu" against the entry so the routing is unambiguous.
- **`→ new box`** — record the new box slug on the entry. Offer to `box new <slug>` it, but do **not** auto-execute the spun-out work — `close` records the routing, the new box drives the work later.
- **`in-scope-later` that got done** — mark it done with a pointer to where it landed (the merged change, the track item, the commit).
- **`dropped`** — an explicit kill, with a one-line reason on the entry. A dropped follow-up keeps its `F<id>` forever; it is killed, not deleted.

If a follow-up genuinely can't be reconciled (Stu's away, the routing target is unknown), don't invent a disposition — surface it and ask. Limbo is the failure mode `close` exists to prevent; an honest "this one needs your call" beats a fabricated kill.

### 4. Demote done work to `archive/`

Per the contract's archival rule, demote done and superseded documents out of the active surface into `archive/`. For each demoted doc:

- Add the death-banner at the top, in-doc — the same format `rollup` uses: `**SUPERSEDED (<date>) — see <X>. Do not act on this.**` where `<X>` names where the live truth now lives (the merged PR, the successor box, the closing summary).
- Add closing frontmatter: `superseded_by: <X>` and a closing date.
- Move the file into `archive/` (created on demand if it doesn't exist).
- Append a `superseded:<doc>` Log event per demotion — one event each, naming the doc and where it went.

Done items' Next-moves track lines are folded out of the active view by the rollup in step 2; `close` doesn't re-archive those track lines. (Whether a done item's *bodies* under `items/<id>/` should also be demoted to `archive/` is the open demotion-ownership question flagged for review — see Notes.)

**Keep open questions visible.** If the box closes with unresolved open questions, they stay surfaced in the README — archival demotes the *done*, never the *undecided*. Closing with open questions is a deliberate, recorded "yes, leaving these open", not a silent drop (see step 5).

### 5. Record terminal state

Write a **closing summary block** in the README **static zone** (above the projected-zone markers — not inside them; the projected zone is rollup's, and `close` is terminal, hand-curated state). Add it as a `## Closing summary` section. It carries:

- **Terminal state:** `done` / `spun-out` / `abandoned` / `superseded-by <slug>`.
- **Outcome:** one paragraph — what the box achieved (or didn't) and why it's ending.
- **Links:** the merged PR, any spun-out issue URLs, the successor box slug — whatever the terminal state points at.

Before writing, **warn and force a deliberate acknowledgement** if either holds:

- A track item is still `ready`/`needs-discovery` with real work left — the box is closing with work unfinished.
- An open question is still unresolved — name the specific `Q<id>`s left open (e.g. "closing with Q2, Q4 unresolved").

Don't block — Stu may legitimately close a box with loose ends — but make him say so. The acknowledgement is recorded in the closing summary ("closed with X unresolved, deliberately") and in the `closed` Log event. Silent closure over loose ends is the thing to prevent.

### 6. Draft the PR description

Compose a PR-description **DRAFT** from the box, then **PRINT it to the conversation** for Stu to copy and send. Never post — draft only, per Stu's standing rule.

Source it from the box but translate fully into leak-free plain English: intent from `## The prize`, the shipped (done) items, resolved decisions from the Log, and any caveats or known follow-ups worth flagging to a reviewer. Carry **none** of the box's internal vocabulary — no `F<id>`, no slug, no "the box found…", no `plan.md`/`follow-ups/` pointers. Write it the way a person would naturally describe the change to a reviewer who's never heard of the box.

If the terminal state is `abandoned` or `spun-out` with nothing merged, there may be no PR to describe — say so and skip, rather than drafting a hollow description.

### 7. Closing Log event + commit

The pre-close snapshot was taken at step 2a. Write the closing Log event `log/YYYY-MM-DDTHH-MM-closed.md` from `${CLAUDE_SKILL_DIR}/templates/log-entry.md` (event type `closed`). It records:

- The terminal state.
- A per-`F<id>` follow-up reconciliation summary — each open follow-up and where it went (`→ issue` + URL, `→ new box` + slug, done + pointer, or dropped + reason).
- Any still-open questions, recorded by `Q<id>` (the deliberate "closed with Q2, Q4 unresolved" from step 5) — they keep their IDs and stay visible in the README.
- The outcome in one line, and any deliberate loose ends acknowledged in step 5.

The Log is append-only — never edit an event after writing it. After writing everything, commit `box: close <slug>`.

### 8. Report

Short summary back to the user:

- Terminal state recorded.
- How many follow-ups reconciled, and to where (e.g. "3 reconciled: 1 → issue, 1 → new box `worker-backpressure`, 1 dropped").
- How many docs archived.
- The reminder: **the PR description draft is printed above, ready for you to send** — I haven't posted it.

If anything was left deliberately open (a loose track item, an unresolved question), name it in one line so the closure is honest.

## Notes

- **`close` is the normal ending for a box, not an edge case.** Most boxes end here; the design treats reconciliation-at-close as the ~70% tail-end workflow. (It's triage's deferred `close`, promoted to first-class because for box it's the standard finish.)
- **The core value is forcing every follow-up to a terminal disposition.** Parked follow-ups are easy to create and easy to forget; `close` is the moment they'd otherwise rot. Nothing leaves `close` still parked — every open `F<id>` reconciles to `→ issue`, `→ new box`, done, or `dropped`.
- **Open questions may survive `close`** — but only as a deliberate, recorded choice (step 5), never a silent drop. Visibility over tidiness; archival demotes the done, never the undecided.
- **The PR draft is draft-only.** `close` composes and prints it; Stu sends it. The same leak-free rule governs any GitHub issue drafted during reconciliation. Per Stu's standing rule, nothing public is posted unprompted.
- **`close` records routing; it does not execute spun-out work.** A `→ new box` follow-up gets a slug and an offer to `box new` it — not the work itself. A `→ issue` follow-up gets a drafted issue — not a posted one.
- **Open: demoting done item *bodies*.** The state→artefact tables (SKILL.md, `templates/plan-item.md`) say a `done` item is "demoted to `archive/`", and `do` (`do.md` step 7) defers that demotion to `rollup`/`close`. But `rollup` currently leaves done items ticked in place and demotes only *superseded documents*, and `close` step 4 demotes only superseded docs too — so a done item's `items/<id>/spec.md` + `plan.md` stay on the active surface at close. Whether `close` (or `rollup`) should also move done item bodies into `archive/`, and which verb owns that, is unresolved and left for a deliberate design call rather than fixed here — it touches the rollup-vs-close demotion boundary.
