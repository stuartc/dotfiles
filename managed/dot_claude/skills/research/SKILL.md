---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.
---

Spin up a **background agent** to do the research, so you keep working while it reads.

Its job:

1. Investigate the question against **primary sources** — official docs, source code, specs, first-party APIs — not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it to the workbook, never the repo:

   ```
   ~/Documents/Workbook/01-09 Capture & Scratch/01.07 Agent Scratch/<repo>/research/<topic>.md
   ```

   `<repo>` is `basename $(git rev-parse --show-toplevel)`, or the current directory's name outside a git repo. If the research belongs to a wayfinder effort, put it under that effort's directory instead — `<repo>/<effort-slug>/research/<topic>.md`. Say where you saved it.
