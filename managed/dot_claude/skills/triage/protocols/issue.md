# Protocol: issue

Draft a public GitHub issue for the bug under investigation, and record the link back into the investigation. The issue spins the work into the team's tracker; it does **not** close the investigation — the investigation stays open as the diagnostic context that drives the eventual fix (see the lifecycle note in `README.md`).

## When to use

You're stepping out of active triage but want the bug tracked — typically after `findings` confirms a cause, sometimes earlier (a deliberately thin "deprioritised, here's the symptom" issue). The issue quality reflects how far the investigation has got; that's fine, but be honest about it.

This is for the **main bug**. A spinoff problem noticed in passing is a `followup`, not an `issue`.

## Args

`issue [free-text steer]` — optional steer (which repo, severity, an angle to emphasise) passed into the drafting.

## Steps

### 1. Resolve and read

Find the investigation root. Read `README.md`, every `theories/*/brief.md` + `findings.md`, `scope.md`, `shapes.md`, `fix-spec.md` — build the full internal picture of what's known, confirmed, and still open.

### 2. Reconcile before drafting — ask, don't assume

Investigations are usually messy at this point: several theories, some `proposed` and untested, probes with deferred verdicts, overlapping or incomplete threads. **Do not silently dump all of it into an issue.** First, surface the state to Stu and agree what to surface:

- List what's **confirmed** vs **still open** (proposed theories with no findings, inconclusive probes, missing verdicts).
- Flag overlaps and loose ends. Ask explicitly: do we want to **finish or close out** any open thread before cutting the issue (e.g. run a `findings` to land a verdict), or consciously **leave it out** of the issue?
- Confirm the **single narrative** the issue should tell. An issue is not a transcript of the investigation — it's one coherent statement of the problem.

Only proceed to draft once Stu has confirmed scope. If the state is too unsettled to tell a clean story, say so and suggest finishing the open thread first.

### 3. Pick the target repo and template

The issue belongs in the **code repo** (e.g. `openfn/lightning`), never the context repo. Determine the repo from the investigation context or ask.

Look in that repo's `.github/ISSUE_TEMPLATE/` for an appropriate template (bug report, etc.). Pick the best fit and use its structure / required fields / labels. If several plausibly fit, name your pick and confirm. If there's no template directory, fall back to a plain, sensible structure (what's happening / impact / what we know / suggested direction).

### 4. Draft — hand-written, concise, leak-free

Write the issue as **Stu (or a teammate) would actually type it** — natural prose, not a machine-generated dossier. Concise. The reader needs the problem, the impact, what's understood about the cause, and (if known) the fix direction — not every probe and dead-end.

**Leak-free is non-negotiable** (see "Public artefacts never leak the investigation" in `SKILL.md`):

- No theory IDs (`T01`, `T02`), no probe numbers, no `findings.md` / `shapes.md` / slug references, no "the investigation found…".
- Translate the diagnosis into plain English a stranger to the notes would understand.
- The context repo is private and most of the codebase is open source — assume the issue is world-readable.

Present the drafted title + body to Stu in chat.

### 5. Draft only — do not post

Per Stu's standing rule, **never run `gh issue create` unprompted.** Show the draft; create it only if Stu explicitly says so. If he does, run `gh issue create` against the **code repo** with the chosen template's labels.

### 6. Record the linkage (only once the issue exists)

The investigation side can reference the issue freely — it's private.

- Append a `## Spun-out issue` entry to `references.md`: issue URL + number, date, and a one-line note on which state of the investigation it was cut from.
- Add a status line to the README projected zone, e.g. `Issue: #1234 (awaiting fix)`. Non-terminal — the investigation stays open.
- Put a pointer to the investigation slug in the issue body for your own pickup (it's a private path, not a clickable link for others — that's expected).

### 7. Log

Append `log/YYYY-MM-DDTHH-MM-issue-created-<number>.md`:

```
# Issue created: #<number>

URL: <url>
Repo: <owner/repo>
Cut from: <one line on investigation state at spin-out>
```

### 8. Commit

Commit-before-edit applies (investigation side). After: `triage: issue #<number>`.

### 9. Report

One line: the issue ref + that the investigation remains open as the driving context, and `gh issue view <number>` / `gh issue edit` is how to revise the description later from a fresher state.

## Notes

Revising later: because `references.md` holds the issue number, a future session can `gh issue view <number>` to re-read and re-draft the body from the investigation's newer state, then `gh issue edit` — same draft-only, Stu-posts rule applies.
