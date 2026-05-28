# Protocol: rollup

Regenerate the README's projected zone from the source of truth (the log + theory frontmatter).

## When to use

- Before starting a fresh session, to make sure the README reflects current state
- After a burst of activity where multiple theories or probes have shifted
- Any time the README feels out of sync with the artefacts
- When asked

The user runs this by hand. There's no auto-trigger.

## Args

`rollup` — no args.

## Steps

### 1. Resolve

Find the investigation root.

### 2. Read the source-of-truth files

- All `theories/*/brief.md` — read frontmatter for `id`, `status`, `shapes`. Read first paragraph of body for the mechanism summary.
- All `theories/*/findings.md` if present — read the verdict headline.
- Last 5 files in `log/` sorted by filename (which is timestamped, so latest 5 events).
- `shapes.md` if it exists — for the canonical shape list.
- `scope.md` if it exists — for the headline number.
- `fix-spec.md` if it exists — for the link.

### 3. Compose the projected zone

Replace **only** the projected zone of `README.md` (between the markers — see the README template). The static zone above the marker is never touched by rollup.

Sections in the projected zone, in this order:

```markdown
<!-- TRIAGE: BEGIN PROJECTED -->

## Status

_Last rolled up: <ISO datetime>_

## Scope

<headline from scope.md, or "Not yet scoped" if missing>

## Shapes

<bulleted list from shapes.md, or "Not yet categorised">

- A — <one-line signature>
- B — <one-line signature>

## Theories

| ID | Slug | Status | Mechanism | Shapes |
|---|---|---|---|---|
| T01 | pod-collision | falsified | Insert collision under load | A |
| T02 | process-events | confirmed | Events processed out of order | A,B |
| T03 | retention-wipe | proposed | … | C |

## Confirmed root causes

<only if any theories are confirmed — link to findings + fix-spec>

## Recent activity

<last 5 log events as bullets — timestamp + headline + path>

## Fix spec

<link to fix-spec.md, or "Not yet drafted">

<!-- TRIAGE: END PROJECTED -->
```

### 4. Write the README

Read the current README. Preserve everything outside the `<!-- TRIAGE: BEGIN PROJECTED -->` … `<!-- TRIAGE: END PROJECTED -->` markers. Replace the contents between them with the freshly composed projection.

If the markers are missing (eg. someone hand-edited them out), warn the user and ask before reconstructing.

### 5. Commit

Commit-before-edit applies. After: `triage: rollup <slug>`.

### 6. Report

One line: "README projected zone regenerated. N theories, M proposed / K confirmed / L falsified."

## Notes

Rollup is **derived data**. The README's projected zone is replaceable; the source files (`theories/*/brief.md`, `log/*.md`) are the truth. If you ever need to recover from a botched rollup, just delete the projected zone and re-run.

The static zone above the marker is hand-curated at intake and rarely changes. If the symptom statement evolves or the vocabulary needs updating, edit the static zone manually — rollup won't touch it.
