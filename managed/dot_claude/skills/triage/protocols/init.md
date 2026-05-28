# Protocol: init

Scaffold a new investigation folder.

## Args

`init <slug> [--sentry REF | --gh REF | --pr REF | --note "free text"]`

- `<slug>` — kebab-case, descriptive. Example: `wg-shape-investigations`, `stuck-runs`.
- Reference flags are optional and can be combined.

## Steps

### 1. Resolve the location

Run `pwd` to confirm you're in a project root. Check for `.context/` — it's usually a symlink to a per-project context repo.

- If `.context/stuart/investigations/` exists → use it
- If `.context/` exists but no `stuart/investigations/` → create the path
- If `.context/` doesn't exist → **stop and ask** the user where to put the investigation. Don't guess and don't scaffold inside the project tree by default.

Final path: `.context/stuart/investigations/<slug>/`. If it already exists, **stop and ask** before doing anything destructive.

### 2. Pull references

If `--sentry <REF>` was passed, use the Sentry MCP to fetch the issue: title, error message, occurrence count, first-seen / last-seen, affected projects, latest event sample. Save the raw payload to a thinkable summary in `references.md`.

If `--gh <REF>` (e.g. `openfn/lightning#1234`), use `gh issue view <REF>` (and `gh issue view <REF> --comments` if comments are likely useful). Save title + body + comment thread summary.

If `--pr <REF>`, use `gh pr view <REF>` and capture diff summary + description.

If `--note "..."`, take it as the free-text symptom.

Multiple flags compose — record each as its own section in `references.md`.

If none were passed, leave `references.md` with a single line: `_No references at intake._`

### 3. Scaffold the folder

Create:

```
<slug>/
├── README.md           # from templates/README.md, substituting slug + date
├── references.md       # contents from step 2
├── log/
│   └── YYYY-MM-DDTHH-MM-intake.md
├── theories/           # empty
├── probes/             # empty
└── scripts/            # empty, see step 4
```

### 4. Runner scripts

Don't auto-generate runners — they vary too much by project. Instead, write a `scripts/README.md` that says:

> Runner scripts for this investigation. Conventions:
>
> - `run-sql.sh probes/NN.sql > probes/NN.out` — execute a SQL probe in the target environment
> - `run-iex.sh probes/NN.iex > probes/NN.out` — execute an IEx probe
>
> Implementation is project-specific (kubectl exec, ssh, local psql, etc.). Look at sibling investigations under `../` for templates if any exist, or ask Stu to provide one. If a runner doesn't exist when a probe is written, the probe protocol will hand back the script + ask Stu to set up the runner or run it manually.

Check `../` for sibling investigations. If any have a `scripts/run-*.sh`, mention them in a note at the top of the new `scripts/README.md` so they can be cribbed.

### 5. Populate the README

Use `templates/README.md` from this skill. Fill the static zone:

- **Slug** — `<slug>`
- **Created** — today's date (ISO)
- **Symptom** — from the references or the `--note` flag. If neither, leave a placeholder asking Stu to fill it in.
- **Scope** — leave empty if not yet known
- **Vocabulary** — leave empty, populated by `taxonomy` later

The projected zone (current theories, last events) starts empty.

### 6. Log the intake event

Write `log/YYYY-MM-DDTHH-MM-intake.md` with:

```
# Intake

Slug: <slug>
Created: <ISO datetime>
References:
- <ref 1, if any>
- <ref 2, if any>

Initial symptom:
<one paragraph from references / --note / "to be filled in">
```

### 7. Commit

`git add -A` from the `.context/` symlink target (`cd` into it first, since it's likely its own git repo). Commit message: `triage: init <slug>`.

If the `.context/` is not a git repo, skip the commit and tell the user.

### 8. Report

One paragraph back to the user:

- Path scaffolded
- What references were pulled (if any)
- Suggested next step: usually `/triage scope` (to size the problem) or `/triage hypothesise` (if it's already well-scoped from references)

## Discovery rule

If pulling a Sentry issue, **do not paginate through events at intake**. Just fetch the issue summary + 1 sample event. Pagination belongs to `taxonomy` or `scope` where it's the user's explicit ask. This is the stuck-agent rule.
