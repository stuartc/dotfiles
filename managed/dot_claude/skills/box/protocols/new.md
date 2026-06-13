# Protocol: new

Create a box. Scaffold the tree, write the README, log the first event, commit. `new` produces an artefact — it does **not** start doing the work (per the plan-vs-execute boundary in SKILL.md).

## Args

`new <slug> [--pr REF | --issue REF]`

- `<slug>` — kebab-case, descriptive. Example: `worker-backpressure`, `collections-export`.
- `--pr REF` / `--issue REF` — optional seed. At most one. `REF` is a `gh` ref, e.g. `openfn/lightning#1234` or a URL.
- No flag → fill in the origin from the live session.

## Steps

### 1. Resolve the location

Run `pwd` to confirm you're in a project root. Check for `.context/` — usually a symlink to a per-project context repo.

- If `.context/stuart/boxes/` exists → use it.
- If `.context/` exists but no `stuart/boxes/` → create the path.
- If `.context/` doesn't exist → **stop and ask** the user where to put the box. Don't guess and don't scaffold inside the project tree.

Final path: `.context/stuart/boxes/<slug>/`. If `<slug>/` already exists, **stop and ask** before doing anything destructive.

### 2. Origin / seed

Three kickoff modes, picked by the flag (or absence of one).

**No flag.** Fill in the origin from the live session: what was being worked on, and the question or realisation that made this worth keeping. This becomes `## Origin` and informs `## The prize`. Don't interrogate Stu — reconstruct from what's already in the session, and ask only if the intent is genuinely unclear.

**`--pr REF`.** Run `gh pr view <REF>` for the title, description, and state, plus `gh pr diff <REF> --stat` for the shape of the change. Seed `## Origin` from the PR (ref, author, what it does) and the first `## Track` items from what the PR still needs. Log event `seeded-from-pr`.

**`--issue REF`.** Run `gh issue view <REF>` (add `--comments` only if the thread clearly matters). Seed `## Origin` from the issue and the first `## Track` items from what it asks for. Log event `seeded-from-issue`.

Apply the discovery-before-commitment rule (see below): fetch the summary and one level of detail — no fan-out, no pagination through history.

### 3. Scaffold the README

Copy `${CLAUDE_SKILL_DIR}/templates/README.md` into `<slug>/README.md`, substituting slug + today's date. Fill the static zone:

- **`## The prize`** — the intent and what "done" looks like.
- **`## Repo facts`** — repo, branch, key paths, build/test commands. Leave a placeholder for anything you can't determine cheaply rather than guessing.
- **`## Origin`** — from step 2. History, not status.
- **`## Track`** — seed the index with a first item or two, each a line per `${CLAUDE_SKILL_DIR}/templates/plan-item.md` (`` - [ ] <id> · <one-liner>  `[state]` ``). When the box opens around something large, steer towards a decomposition/design item as the head (`D1`) whose job is to list the other items, rather than one all-encompassing item. A seeded box usually yields one or two `[ready]` items; an unseeded box may be a single `[stub]` or a decomposition head.

Leave the projected zone exactly as the template ships it — the empty sections between the markers. `new` does not rollup.

The box starts as **just `README.md`** plus the first log entry. Don't create `items/`, `follow-ups/`, `handoffs/`, or `archive/` — each appears on first use, from its own verb.

### 4. First log event

Create `log/YYYY-MM-DDTHH-MM-<event>.md` from `${CLAUDE_SKILL_DIR}/templates/log-entry.md`, where `<event>` is `born` (no seed flag), `seeded-from-pr`, or `seeded-from-issue`.

Fill it: slug, created ISO datetime, origin/refs (the PR/issue ref, or "live session"), and a one-paragraph statement of intent. 5–20 lines.

### 5. Commit

`new` is the exception to the commit contract in SKILL.md — there's no prior state to snapshot, so it commits once after scaffolding: `box: new <slug>`. Pathspec scoping applies as usual; never `add -A`.

### 6. Report

One paragraph back to the user: the path scaffolded, what was seeded (if anything), and the suggested next step — usually `box plan` (lay out the work) or `box status` (read the head back). Do **not** begin executing the work.

## Discovery rule

When seeding from a PR or issue, **do not paginate** through commits, diffs, or comment threads. Fetch the summary (`gh pr view` / `gh issue view`) and one level of detail (a diff stat, or `--comments` only if clearly needed). Confirm the data shape in ≤5 calls, seed from it, and let `plan` flesh out the rest when the work is reached.
