---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work.

Save it to the OS temp directory as `handoff-YYYY-MM-DD-<slug>.md`, where `<slug>` is a short kebab-case identifier for the work (e.g. `fix-issue-42`, `implement-auth`, `prototype-window-comms`). Tell the user the full path when done.

Include a "Suggested skills" section listing skills the next agent should invoke (e.g. `grill-with-docs`, `diagnose`, `prototype`, `tdd`).

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, GitHub issues, commits, diffs). Reference them by path or URL instead — handoffs go stale fast, source artifacts don't.

Redact any sensitive information (API keys, passwords, PII).

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the document accordingly. If no arguments were given, ask the user what the next session's purpose is before writing — a handoff without a stated purpose isn't useful.
