---
name: to-tickets
description: Break a plan or spec into independently-grabbable tickets using tracer-bullet vertical slices, written out as one file per ticket for the user to promote to a tracker themselves.
disable-model-invocation: true
---

# To Tickets

Break a plan into independently-grabbable tickets using vertical slices (tracer bullets).

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a spec path, a ticket number or URL) as an argument, fetch it and read its full body and comments.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the plan into **tracer bullet** tickets. Each ticket is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

<vertical-slice-rules>

- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change — rename a column, retype a shared symbol — whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket — green is promised only there.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct — does each ticket only depend on tickets that genuinely gate it?
- Should any slices be merged or split further?

Iterate until the user approves the breakdown.

### 5. Write the tickets out

Write one file per approved slice, in dependency order (blockers first), to the workbook — never the repo, and **never straight onto a public tracker**:

```
~/Documents/Workbook/01-09 Capture & Scratch/01.07 Agent Scratch/<repo>/<effort-slug>/issues/<NN>-<slug>.md
```

`<repo>` is `basename $(git rev-parse --show-toplevel)`, or the current directory's name outside a git repo. Number from `01`. One ticket per file, never a single combined file. Use the template below, with "Blocked by" listing the numbers and titles it depends on.

A batch of a dozen tickets appearing on a public tracker at once is the user's decision to make, one ticket at a time — so stop here and tell them where the files are. Only open real tracker issues when they ask, for the specific ones they name, and then use the tracker's native blocking or sub-issue relationship where it has one.

Work the **frontier**: any ticket whose blockers are all done. For a purely linear chain that means top to bottom.

<ticket-template>
## Parent

A reference to the parent ticket or spec (if the source was an existing one, otherwise omit this section).

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

Avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it here and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by

- A reference to the blocking ticket (if any)

Or "None - can start immediately" if no blockers.

</ticket-template>

Do NOT close or modify any parent ticket.
