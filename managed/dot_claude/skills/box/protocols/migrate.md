# Protocol: migrate

Bring an existing box up to the current schema (`box_schema: 1.3`). Migration is the **drift-control lever**: every future review round reads `box_schema` from the README frontmatter and compares like-for-like, and `migrate` is how a straggler converges. It is **structural only** — it moves files, splits monolithic ones into folders, and re-stamps the schema. It never rewrites the *content* of an item, never reinterprets a plan, and never renumbers an ID.

`migrate` is **safe to re-run**: a box already at the current schema is a no-op. It is the one verb that may touch many files at once, so it leans hard on commit-before-edit and reports a clear diff plus a "needs manual attention" list rather than guessing.

## Args

`migrate [path]`

- `[path]` — optional box root. Omitted → resolve per the standard contract (the box pointed at, or the most-recently-modified box under `.context/stuart/boxes/`). Ask only if genuinely ambiguous.

## Steps

### 1. Resolve & read the schema stamp

Resolve the box root. Read `box_schema` from the README YAML frontmatter:

- **`1.3`** (current) → already converged. Skip to step 7 and report a no-op. Do not commit, do not touch a thing.
- **absent** → treat as **pre-1.0** (boxes born before the stamp existed have no frontmatter at all — the README opens straight with `# Box: <slug>`).
- **`< 1.3`** → an intermediate schema; migrate forward.

Migration only ever moves **forward**. If `box_schema` reads *higher* than the current schema, stop and tell the user — don't downgrade.

### 2. Snapshot (commit-before-edit)

This verb rewrites many files, so the snapshot matters more here than anywhere. Take it per the contract's commit-before-edit rule (`box: snapshot before migrate`). The one heightened nuance: if `.context/` isn't a git repo, don't just skip silently — tell the user there's no safety net and ask before proceeding.

### 3. Split follow-ups → `follow-ups/<F-id>.md`

If a monolithic `follow-ups.md` exists, split it into one file per follow-up under `follow-ups/`, named by the existing ID (`follow-ups/F1.md`, `follow-ups/F3.md`, …):

- **Preserve IDs and bodies exactly.** A dropped or spun-out follow-up keeps its ID and its file — IDs are never reused or renumbered (the standing rule). Gaps are fine: `F1`, `F3` with no `F2` is correct if `F2` never existed or was renumbered away historically — do not backfill.
- Carry the disposition tag across unchanged (`in-scope-later` / `→ issue` / `→ new box` / `dropped`).
- Once every entry is migrated, delete the old `follow-ups.md`.
- If `follow-ups/` already exists and `follow-ups.md` does not, this is already done — skip it.

### 4. Hoist the plan into `items/<id>/`

This is the lossy, best-effort step — be conservative and record anything you're unsure of for manual attention rather than inventing structure. Three source shapes to handle:

- **Inline `## Plan` in the README** (the common case — e.g. the dependabot fixture) — each plan item becomes an `items/<id>/` folder. Use a short kebab-case id derived from the item's intent (`bucket-core`, not `item-1`). Drop the item's current text into a **`plan.md` placeholder** in that folder so nothing is lost. Leave the README's inline plan in place for now but mark it superseded by the item folders (the projected-zone track will index `items/` after the next `rollup`).
- **A single split `plan.md`** at the box root — same treatment: one item folder per plan item, each seeded with a `plan.md` placeholder carrying that item's text.
- **A hand-grown `plans/*.md` folder** (the flaky-tests pattern — Stu reinvented per-item files by hand; this is the strongest signal v1.3 ratifies) — each `plans/<name>.md` is *already* an addressable item. Move it to `items/<name>/plan.md` verbatim. This is the cleanest migration: it's a rename, not a reinterpretation.

For every hoisted item, set its state on the track per the existing convention (`stub` / `needs-discovery` / `ready` / `done`), inferred from the source where possible, left as `needs-discovery` (or recorded for manual attention) where it's ambiguous. **Do not author a `spec.md`** — spec is optional and only written when there's genuine discovery to do; a hoist has nothing to discover. A `plan.md` placeholder per item is the floor.

Whatever can't be cleanly mapped — an item whose intent is unclear, a `plans/` file that's really notes not a plan, a plan that interleaves several items — goes on the **"needs manual attention"** list (step 7) rather than being force-fit.

### 5. Normalise structure

- **Projected-zone markers.** Ensure the README carries `<!-- BOX: BEGIN PROJECTED -->` / `<!-- BOX: END PROJECTED -->` around its projected zone. If they're missing (a pre-marker box), insert them around the existing "Where things stand"-style content; if you can't identify that zone confidently, flag it for manual attention rather than guessing where the static/projected boundary sits.
- **Log filenames.** Normalise any colon in a `log/` filename to a hyphen (`…question-resolved:Q3.md` → `…question-resolved-Q3.md`) — colons are a portability footgun and the hyphenated form is what `rollup` scans. Use `git mv` so history follows.

### 6. Re-stamp `box_schema: 1.3`

Add or update the `box_schema: 1.3` field in the README YAML frontmatter. If the README has **no** frontmatter (pre-1.0), prepend a minimal block:

```
---
box_schema: 1.3
---
```

immediately above the `# Box: <slug>` heading. This stamp is the durable fix for drift — it is the single field every future migration and review round keys off.

### 7. Commit & report

If anything changed, commit `box: migrate <slug> → 1.3`. If nothing changed (an already-1.3 box, step 1), there is no commit.

Report, in this order:

- **Outcome** — `migrated <slug> → 1.3` or `no-op (already 1.3)`.
- **Diff summary** — counts: N follow-ups split, M plan items hoisted to `items/`, K log filenames normalised, markers inserted (yes/no), schema re-stamped (from → to).
- **Needs manual attention** — the explicit list from steps 4–5: ambiguous items, unidentifiable projected zone, anything force-fitting would have corrupted. If the list is empty, say so — "nothing needs manual attention" is a real and good outcome.
- **Suggested next step** — usually `box rollup` (to regenerate the projected-zone track over the freshly-hoisted `items/`) so the README index reflects the new shape.

## Notes

- **Idempotent by design.** Re-running `migrate` on a 1.3 box reads the stamp at step 1 and stops — no commit, no churn. This is what makes it safe to run across a whole fleet of boxes to converge stragglers.
- **Structural, never semantic.** `migrate` moves and stamps; it does not rewrite item content, re-cut a plan into different items, or decide what a spec should say. The thinking stays the human's — `migrate` only changes the *shape*, never the *substance*.
- **Never renumber.** F-IDs and Q-IDs survive migration exactly as they were. A gap in the sequence is correct, not a bug to fix.
- **Real-box migration is a separate, later call.** v1.3 ships `migrate` and tests it against a *copy* of an old box; running it across the four real boxes (flaky-tests, pr-4751-sso-review, dependabot-remediation, quickbeam-openfn-spike) is a deliberate later decision, out of scope for the build.
- **Discovery before commitment.** All local file reads — no fan-out. Don't paginate the whole log history to normalise filenames; list the directory and rename in place.
