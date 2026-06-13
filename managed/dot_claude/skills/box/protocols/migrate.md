# Protocol: migrate

Bring an existing box up to the current schema (`box_schema: 1.3`). Every review round reads `box_schema` from the README frontmatter and compares like-for-like; `migrate` is how an out-of-date box converges. It is **structural only** — it moves files, splits monolithic ones into folders, and re-stamps the schema. It never rewrites the *content* of an item, never reinterprets a plan, and never renumbers an ID.

`migrate` is safe to re-run: a box already at the current schema is a no-op. It is the one verb that may touch many files at once, so the pre-edit snapshot matters most here, and it reports a clear diff plus a "needs manual attention" list rather than guessing.

## Args

`migrate [path]`

- `[path]` — optional box root. Omitted → resolve per SKILL.md. Ask only if genuinely ambiguous.

## Steps

### 1. Resolve and read the schema stamp

Resolve the box root. Read `box_schema` from the README YAML frontmatter:

- **`1.3`** (current) → already converged. Skip to step 7 and report a no-op. Do not commit, do not touch a thing.
- **absent** → treat as pre-1.0 (boxes from before the stamp existed have no frontmatter at all — the README opens straight with `# Box: <slug>`).
- **`< 1.3`** → an intermediate schema; migrate forward.

Migration only ever moves forward. If `box_schema` reads *higher* than the current schema, stop and tell the user — don't downgrade.

### 2. Snapshot

Per the commit contract in SKILL.md (`box: snapshot before migrate`). One heightened rule for this verb: if `.context/` isn't a git repo, don't skip silently — tell the user there's no safety net and ask before proceeding.

### 3. Split follow-ups → `follow-ups/<F-id>.md`

If a monolithic `follow-ups.md` exists, split it into one file per follow-up under `follow-ups/`, named by the existing ID (`follow-ups/F1.md`, `follow-ups/F3.md`, …):

- **Preserve IDs and bodies exactly** (per the ID rules in SKILL.md). Gaps are fine: `F1`, `F3` with no `F2` is correct — do not backfill.
- Carry the disposition tag across unchanged.
- Once every entry is migrated, delete the old `follow-ups.md`.
- If `follow-ups/` already exists and `follow-ups.md` does not, this step is already done — skip it.

### 4. Move the plan into `items/<id>/`

This is the lossy, best-effort step — be conservative and record anything you're unsure of for manual attention rather than inventing structure. Three source shapes:

- **Inline `## Plan` in the README** (the common case) — each plan item becomes an `items/<id>/` folder. Use a short kebab-case id derived from the item's intent (`bucket-core`, not `item-1`). Drop the item's current text into a `plan.md` placeholder in that folder so nothing is lost. Leave the README's inline plan in place for now but mark it superseded by the item folders (the projected-zone track will index `items/` after the next `rollup`).
- **A single `plan.md`** at the box root — same treatment: one item folder per plan item, each seeded with a `plan.md` placeholder carrying that item's text.
- **A hand-grown `plans/*.md` folder** — each `plans/<name>.md` is already an addressable item. Move it to `items/<name>/plan.md` verbatim. This is the cleanest case: a rename, not a reinterpretation.

For every moved item, set its state on the track per the standard convention, inferred from the source where possible, left as `needs-discovery` (or recorded for manual attention) where it's ambiguous. **Do not write a `spec.md`** — a spec is only written when there's genuine discovery to do; a migration has nothing to discover. A `plan.md` placeholder per item is the floor.

Whatever can't be cleanly mapped — an item whose intent is unclear, a `plans/` file that's really notes, a plan that interleaves several items — goes on the "needs manual attention" list (step 7) rather than being force-fitted.

### 5. Normalise structure

- **Projected-zone markers.** Ensure the README carries the `<!-- BOX: BEGIN PROJECTED -->` / `<!-- BOX: END PROJECTED -->` pair around its projected zone. If they're missing, insert them around the existing "Where things stand"-style content; if you can't identify that zone confidently, flag it for manual attention rather than guessing where the static/projected boundary sits.
- **Log filenames.** Normalise any colon in a `log/` filename to a hyphen (`…question-resolved:Q3.md` → `…question-resolved-Q3.md`) — the hyphenated form is what `rollup` scans. Use `git mv` so history follows.

### 6. Re-stamp `box_schema: 1.3`

Add or update the `box_schema: 1.3` field in the README YAML frontmatter. If the README has no frontmatter (pre-1.0), prepend a minimal block:

```
---
box_schema: 1.3
---
```

immediately above the `# Box: <slug>` heading.

### 7. Commit and report

If anything changed, commit `box: migrate <slug> → 1.3`. If nothing changed (an already-1.3 box, step 1), there is no commit.

Report, in this order:

- **Outcome** — `migrated <slug> → 1.3` or `no-op (already 1.3)`.
- **Diff summary** — counts: N follow-ups split, M plan items moved to `items/`, K log filenames normalised, markers inserted (yes/no), schema re-stamped (from → to).
- **Needs manual attention** — the explicit list from steps 4–5. If the list is empty, say so — "nothing needs manual attention" is a real and good outcome.
- **Suggested next step** — usually `box rollup`, so the README index reflects the new shape.

## Notes

- **Structural, never semantic.** `migrate` moves and stamps; it does not rewrite item content, re-cut a plan into different items, or decide what a spec should say. It changes the shape, never the substance.
- **Migrating the real boxes is a separate, later call.** v1.3 ships `migrate` tested against a *copy* of an old box; running it across the real boxes is a deliberate later decision.
- All local file reads — no fan-out. Don't paginate the whole log history to normalise filenames; list the directory and rename in place.
