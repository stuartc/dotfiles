# Issue tracker: Local Markdown

Everything lives as markdown under a fixed root in the workbook, scoped by the
repo it belongs to. **Nothing is written into the repo itself and nothing is
pushed** — most of these repos are public, and a map is thinking in progress.

```
~/Documents/Workbook/01-09 Capture & Scratch/01.07 Agent Scratch/<repo>/
├── CONTEXT.md                     ← domain glossary (/domain-modeling)
├── adr/0001-<slug>.md             ← decision records (/domain-modeling)
└── <effort-slug>/
    ├── map.md                     ← the wayfinder map
    ├── spec.md                    ← if the effort's destination is a spec
    ├── issues/NN-<slug>.md        ← one file per ticket
    ├── research/<topic>.md        ← findings from /research
    └── prototypes/<name>/         ← artifacts from /prototype
```

`<repo>` is `basename $(git rev-parse --show-toplevel)`. Outside a git repo, use
the basename of the current working directory. Create directories lazily — only
when there is something to write.

## Conventions

- One effort per directory: `<root>/<repo>/<effort-slug>/`
- Tickets are one file each under `issues/`, numbered from `01` — never a single
  combined file
- Ticket state is a `Status:` line near the top of each file
- Comments and conversation history append to the bottom under a `## Comments`
  heading

## When a skill says "publish to the issue tracker"

Create a new file under `<root>/<repo>/<effort-slug>/`, creating the directory
if needed. Never open a GitHub issue unless the user asks for that specifically —
promoting a ticket to a public tracker is their call, made per ticket.

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or
the ticket number directly.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a file with one **child** file per ticket.

- **Map**: `<root>/<repo>/<effort-slug>/map.md` — the Destination / Notes /
  Decisions-so-far / Not-yet-specified / Out-of-scope body.
- **Child ticket**: `<root>/<repo>/<effort-slug>/issues/NN-<slug>.md`, numbered
  from `01`, with the question in the body. A `Type:` line records the ticket
  type (`research`/`prototype`/`grilling`/`task`); a `Status:` line records
  `open`/`claimed`/`resolved`/`out-of-scope`.
- **Blocking**: a `Blocked by: NN, NN` line near the top. A ticket is unblocked
  when every file it lists is `resolved`.
- **Frontier**: scan `<root>/<repo>/<effort-slug>/issues/` for files that are
  open, unblocked, and unclaimed; first by number wins.
- **Claim**: set `Status: claimed` and save before any work.
- **Resolve**: append the answer under an `## Answer` heading, set
  `Status: resolved`, then append a context pointer (gist + relative link) to
  the map's Decisions-so-far in `map.md`.
- **Rule out of scope**: set `Status: out-of-scope` and add the one-line gist
  plus reason to the map's Out-of-scope section, linking the file.

Since names rather than numbers are what the human reads, every link is written
as `[<ticket title>](issues/NN-slug.md)`.
