# Protocol: pickup

Resume from a specific handoff document, treating it as a brief to act on. `pickup` is the **box-aware counterpart to the standalone `/pickup` skill**: because you are invoking this through the box skill, the box vocabulary is already loaded — unlike the standalone `/pickup`, which knows nothing about boxes and cannot interpret box-specific content correctly.

`pickup` is targeted: it resumes from a named handoff. `open` is general: it resumes from the README head. Both load the vocabulary; the choice is about *entry point* — use `pickup` when there's a specific carry-forward handoff to act on; use `open` for a general re-entry into the box's current state.

## Args

`pickup [path]` — optional explicit path to a handoff file.

- With a path → use it directly.
- Without a path → find the most recent file in `$BOX_ROOT/handoffs/` (sort by filename — they're timestamped `YYYY-MM-DDTHH-MM-<slug>.md`).
- If `handoffs/` doesn't exist or is empty, say so and suggest `box open` for general re-entry or `box status` for orientation.

## Steps

### 1. Resolve the handoff and the box root

If an explicit path was given, use it. Otherwise, resolve the box root first (`.context/stuart/boxes/<slug>/`, or the box the user pointed at, or the most-recently-modified box), then find the most-recent file under `$BOX_ROOT/handoffs/`.

Confirm the handoff file exists. If it doesn't, say so plainly.

From the handoff's location, confirm the box root: handoffs live at `<box>/handoffs/<file>`, so `$BOX_ROOT` is the parent of the `handoffs/` directory the file sits in. (If an explicit path points somewhere non-standard, resolve the box root from the box-root contract instead, and warn that the handoff is outside the expected `handoffs/` location.)

### 2. Read the handoff and the README head

Read both:

- The handoff document in full.
- The README projected zone (`## Where things stand`, between the `<!-- BOX: BEGIN PROJECTED -->` / `<!-- BOX: END PROJECTED -->` markers) — enough to know if the README state and the handoff are in sync or if there's been drift since the handoff was written.

Do not read every box file before acting — the handoff is the brief; the README head is the cross-check.

### 3. Check for drift

Compare the handoff's "State at handoff" with the current README projected zone and any log entries more recent than the handoff's timestamp. Note any obvious drift:

- Plan items the handoff calls "todo" that now show `done`.
- New log entries since the handoff was written (a burst of commits, a rollup, a new follow-up).
- Missing files the handoff references.

If the drift is significant (the handoff's todos are already done, or the box has moved substantially), flag it to the user before proceeding. Minor drift (one newer log entry, a small commit) is fine to note and proceed through.

### 4. Orient and act

**Treat the handoff as a brief to act on, not a summary to acknowledge.** Read it, orient, and proceed with the first concrete action it names — unless that action is genuinely ambiguous, in which case state your read of it and confirm before starting.

Before acting, read the handoff's **Dead ends / do-not** field and treat it as binding — do not re-attempt an approach listed there without a stated reason to revisit it. Trust the **Validation evidence** for the Done items rather than re-running it from scratch, unless drift (step 3) suggests it's stale.

Print a brief orientation (3–5 lines) acknowledging the box, the handoff's stated purpose, and the first action you're about to take:

```
Box: <slug>
Handoff: handoffs/<filename>
Resuming: <purpose from the handoff>

Starting with: <first concrete action>
```

Then act. Do not recap the handoff body back to the user — they wrote it (or the previous session wrote it for them); they know what it says.

If the handoff's "Suggested skills" section names skills beyond `box`, invoke them now.

## Notes

`pickup` does **not** commit anything of its own. It is read-mostly and action-oriented: read, orient, then proceed. Any commits arise from the work that follows, not from the `pickup` itself.

**Respect the dead-ends.** A handoff's `Dead ends / do-not` list is negative knowledge from the prior session; re-walking it is the waste pickup exists to prevent.

**Box vocabulary is loaded.** Because this protocol runs inside the box skill, terms like `box plan`, `box park`, `box note`, `F<id>`, `Q<id>`, and projected-zone mechanics are all in context. The standalone `/pickup` skill lacks this — if you try to resume a box handoff with the standalone skill, the vocabulary will be missing and the handoff will be harder to act on correctly. That's the reason `pickup` exists as a box verb.

**`pickup` vs `open`:**
- `open` resumes from the README head — general re-entry, works when there's no handoff or when you want current state before deciding what to do next.
- `pickup` resumes from a specific handoff — targeted carry-forward, acts on the brief the previous session left.
Both resolve the box and load vocabulary. Use `pickup` when there's a handoff to act on; use `open` otherwise.
