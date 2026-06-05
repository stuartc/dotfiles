# Protocol: new

Open a box. Scaffold the tree, write the README, log the first event, commit. `new` produces an artefact — it does **not** start doing the work. Stu plans in one session and executes in another; respect that boundary hard. `new` never rolls into execution.

## Args

`new <slug> [--pr REF | --issue REF]`

- `<slug>` — kebab-case, descriptive. Example: `worker-backpressure`, `collections-export`.
- `--pr REF` / `--issue REF` — optional seed. At most one. `REF` is a `gh` ref, e.g. `openfn/lightning#1234` or a URL.
- No flag → born-on-first-value or deliberate: backfill origin from the live session.

## Steps

### 1. Resolve the location

Run `pwd` to confirm you're in a project root. Check for `.context/` — usually a symlink to a per-project context repo.

- If `.context/stuart/boxes/` exists → use it.
- If `.context/` exists but no `stuart/boxes/` → create the path.
- If `.context/` doesn't exist → **stop and ask** the user where to put the box. Don't guess and don't scaffold inside the project tree. "Homeless" means *in a repo with `.context/`, started without a box open* — never *outside a repo*.

Final path: `.context/stuart/boxes/<slug>/`. If `<slug>/` already exists, **stop and ask** before doing anything destructive.

### 2. Origin / seed

Three kickoff modes, same machinery, different doors. Pick by the flag (or absence of one).

**Born-on-first-value / deliberate (no flag).** Backfill the origin from the live session: what was being worked on, and the question or realisation that made this worth keeping. This becomes the `## Origin` section and informs `## The prize`. Don't interrogate Stu — reconstruct from what's already in the session, and ask only if the intent is genuinely unclear.

**`--pr REF`.** Run `gh pr view <REF>` for the title, description, and state, plus `gh pr diff <REF> --stat` (or the diff summary) for the shape of the change. Seed `## Origin` from the PR (ref, author, what it does) and the first `## Plan` items from what the PR still needs. Log event `seeded-from-pr`.

**`--issue REF`.** Run `gh issue view <REF>` (add `--comments` only if the thread is likely load-bearing). Seed `## Origin` from the issue and the first `## Plan` items from what it asks for. Log event `seeded-from-issue`.

Apply the discovery-before-commitment rule (see bottom): fetch the summary and one level of detail, no fan-out, no pagination through history.

### 3. Scaffold the README

Copy `${CLAUDE_SKILL_DIR}/templates/README.md` into `<slug>/README.md`, substituting slug + today's date. Fill the static zone:

- **`## The prize`** — the intent and what "done" looks like. Backfilled from the live session, or distilled from the seed.
- **`## Repo facts`** — repo, branch, key paths, build/test commands. The stable facts a fresh session needs to orient. Leave a placeholder for any you can't determine cheaply rather than guessing.
- **`## Origin`** — from step 2. Provenance, not status.
- **`## Plan`** — seed inline with a first item or two, each carrying a state marker per the contract (`` `[stub]` `` for a placeholder, `` `[ready]` `` for something crisp and actionable). A seeded box usually yields one or two `[ready]` items; a deliberate box may be a single `[stub]`.

Leave the projected zone exactly as the template ships it — the structured empty sections between the `<!-- BOX: BEGIN PROJECTED -->` / `<!-- BOX: END PROJECTED -->` markers. `new` does not rollup.

The box is born as **just `README.md`** plus the first log entry. Don't create `plan.md`, `follow-ups.md`, `handoffs/`, or `archive/` — those accrete on demand from their own verbs.

### 4. First Log event

Create `log/YYYY-MM-DDTHH-MM-<event>.md` from `${CLAUDE_SKILL_DIR}/templates/log-entry.md`, where `<event>` is:

- `born` — no seed flag
- `seeded-from-pr` — `--pr`
- `seeded-from-issue` — `--issue`

Fill it: slug, created ISO datetime, origin/refs (the PR/issue ref, or "live session" for born), and a one-paragraph statement of intent. 5–20 lines. This is the box's second artefact, so `log/` exists from birth.

### 5. Commit

This is creation, not modification, so there's no prior state to snapshot — just stage and commit the new tree.

Resolve the repo root via `readlink -f .context` (it's likely its own git repo), then `git -C <repo> add -A` and `git -C <repo> commit -m "box: new <slug>"`. Do **not** `cd` into the target. No co-author lines, no skip-hooks.

If `.context/` is not a git repo, skip the commit and tell the user.

### 6. Report

One paragraph back to the user:

- Path scaffolded.
- What was seeded (PR/issue ref and what came across), if any.
- Suggested next step: usually `box plan` (to lay out the work) or `box status` (to read the head back). Do **not** begin executing the work — `new` stops at the artefact.

## Discovery rule

When seeding from a PR or issue, **do not paginate** through commits, diffs, or comment threads. Fetch the summary (`gh pr view` / `gh issue view`) and one level of detail (a diff stat, or `--comments` only if clearly needed) — no fan-out. This is the stuck-agent rule: confirm the data shape in ≤5 calls, seed from it, and let `plan` flesh out the rest when the work is reached.
