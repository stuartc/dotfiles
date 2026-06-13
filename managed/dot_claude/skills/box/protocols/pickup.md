# Protocol: pickup

Resume from a specific handoff document, treating it as a brief to act on. `pickup` is the box-aware counterpart to the standalone `/pickup` skill: because it runs through the box skill, the box vocabulary is already loaded — the standalone `/pickup` knows nothing about boxes and cannot interpret box-specific content correctly.

`pickup` is targeted: it resumes from a named handoff. `open` is general: it resumes from the README head. Use `pickup` when there's a specific carry-forward handoff to act on; use `open` otherwise.

## Args

`pickup [path]` — optional explicit path to a handoff file.

- With a path → use it directly.
- Without a path → use the most recent file in `$BOX_ROOT/handoffs/` (sort by filename — they're timestamped `YYYY-MM-DDTHH-MM-<slug>.md`).
- If `handoffs/` doesn't exist or is empty, say so and suggest `box open` or `box status`.

## Steps

### 1. Resolve the handoff and the box root

If an explicit path was given, use it. Otherwise resolve the box root per SKILL.md, then take the most recent file under `$BOX_ROOT/handoffs/`. Confirm the file exists; if it doesn't, say so plainly.

Handoffs live at `<box>/handoffs/<file>`, so `$BOX_ROOT` is the parent of the `handoffs/` directory. If an explicit path points somewhere non-standard, resolve the box root from the SKILL.md rule instead, and warn that the handoff is outside the expected location.

### 2. Read the handoff and the README head

- The handoff document in full.
- The README projected zone (between the markers) — enough to know whether the README state and the handoff are in sync.

Don't read every box file before acting — the handoff is the brief; the README head is the cross-check.

### 3. Check for drift

Compare the handoff's "State at handoff" with the current README projected zone and any log entries newer than the handoff's timestamp:

- Track items the handoff calls "todo" that now show `done`.
- New log entries since the handoff was written.
- Missing files the handoff references.

If the drift is significant (the handoff's todos are already done, or the box has moved substantially), flag it to the user before proceeding. Minor drift is fine to note and proceed through.

### 4. Orient and act

**Treat the handoff as a brief to act on, not a summary to acknowledge.** Read it, orient, and proceed with the first concrete action it names — unless that action is genuinely ambiguous, in which case state your read of it and confirm before starting.

Before acting, read the handoff's **Dead ends / do-not** field and treat it as binding — do not re-attempt an approach listed there without a stated reason. Trust the **Validation evidence** for the Done items rather than re-running it, unless drift (step 3) suggests it's stale.

Print a brief orientation (3–5 lines):

```
Box: <slug>
Handoff: handoffs/<filename>
Resuming: <purpose from the handoff>

Starting with: <first concrete action>
```

Then act. Don't recap the handoff body back to the user — they (or the previous session) wrote it.

If the handoff's "Suggested skills" section names skills beyond `box`, invoke them now.

## Notes

- `pickup` does not commit anything of its own. It is read-mostly: any commits arise from the work that follows.
- The standalone `/pickup` skill lacks the box vocabulary — resuming a box handoff with it leaves `F<id>`, `Q<id>`, and projected-zone mechanics uninterpretable. That's why `pickup` exists as a box verb.
