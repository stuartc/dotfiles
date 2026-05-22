---
name: pickup
description: Resume work from a handoff document. Treats the handoff as a brief to act on, not a summary to acknowledge.
argument-hint: "Handoff filename or slug (optional — defaults to latest)"
---

Find the handoff document and continue the work it describes.

Look in (in order): the OS temp directory for `handoff-*.md`, then `.claude/handoffs/` if it exists in the current project. If an argument was given, fuzzy-match it against the filename/slug; if multiple match, ask which one. With no argument, use the most recently modified.

Read the handoff and **treat its contents as your brief — not a summary to acknowledge back to the user**. The handoff was written so you would act, not recap.

Before acting:
- Verify referenced files, branches, and paths still exist
- Note any obvious state drift since the handoff was written (different branch, missing files, stale references)
- Invoke any skills listed in the handoff's "Suggested skills" section

If something has drifted significantly, flag it to the user before proceeding rather than guessing.
