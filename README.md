# Dotfiles

Managed by [chezmoi](https://www.chezmoi.io/).

## Initial Setup

1. **Install chezmoi:**
   ```bash
   brew install chezmoi
   ```

2. **Clone and apply dotfiles:**
   ```bash
   chezmoi init <your-repo-url>
   chezmoi apply
   ```

3. **Create machine-specific config** at `~/.config/chezmoi/chezmoi.toml`:
   ```toml
   [data]
       projectDir = "~/Sourcecode"
       email = "your.email@example.com"
       fullName = "Your Name"
   ```

4. **Optional: Add Raycast projects** (see [Raycast Integration](#raycast-integration) below)

## Configuration

Machine-specific configuration lives in `~/.config/chezmoi/chezmoi.toml` (not tracked in git).

### Required Data Variables

These variables are used in templates throughout the dotfiles:

```toml
[data]
    projectDir = "~/Sourcecode"    # Where your code projects live
    email = "your@email.com"       # For git config
    fullName = "Your Name"         # For git config
```

## What's Managed

### Shell (Zsh)

- **zshrc** — Sets up PATH, completions, history (10k entries, shared/deduped), and tool integrations
- **Functions** — `c` (quick project navigation with completion), `git-export` (export git patches), `workbook` (daily workbook management)
- **Wrappers** — `rm` → uses `trash` when available; `ssh` → renames tmux window to remote hostname
- **Plugins** — Per-project history (up-arrow prioritises commands from the current project)
- **Tool integrations** — direnv, mise (with asdf fallback), zoxide, fzf, starship prompt, bun
- **Env loading** — Sources `~/.config/env.d/*.env` files at startup for secrets/tokens
- **Editor** — `nvim`

### Git

- **gitconfig** (templated) — Fast-forward only pulls, histogram diffs, zdiff3 conflicts, rerere, auto-stash on rebase, auto-prune on fetch, verbose commits, branch sorting by recency, OS-conditional credential helper (osxkeychain on macOS)
- **gitignore** — Global ignore patterns
- **Aliases** — `co`, `st`, `br`, `rbom` (rebase on origin/main), `count` (contributor shortlog)

### Neovim

NvChad-based config with `github_dark` theme:

- **Finding** — Telescope (with frecency), Harpoon v2 file bookmarks, Snacks command palette
- **Git** — Neogit (Magit-style), Diffview, Gitsigns (inline blame + hunks)
- **Editing** — nvim-surround, vim-visual-multi (multiple cursors), conform.nvim (formatting)
- **Completion** — blink.cmp
- **Languages** — Treesitter, LSP, elixir-tools, beancount
- **Writing** — zen-mode, twilight, render-markdown
- **Other** — nvim-tree, claudecode.nvim (Claude Code IDE integration), snippets (Elixir, JS, Markdown)

### Tmux

- **Prefix** — `Ctrl-Space`
- **Theme** — Catppuccin Macchiato
- **Navigation** — Vim-style pane select (`prefix + h/j/k/l`), Alt-arrows without prefix
- **Copy mode** — Vi keys, mouse drag copies without snapping scroll position
- **Plugins** — tmux-sensible, tmux-suspend (with status bar indicator)
- **Other** — OSC 52 clipboard passthrough (works over SSH), windows indexed from 1

### Terminal & Prompt

- **Ghostty** — Catppuccin Macchiato theme, FiraCode Nerd Font, Option-as-Alt
- **iTerm2** — Managed plist config (macOS)
- **Starship** — Custom success symbol (`➜`), gcloud/aws modules disabled

### Espanso

Date expansion snippets: `;date` → `YYYY.MM.DD`, `;ddate` → `YYYY-MM-DD`, `;sdate` → `YYYY/MM/DD`, `;week` → ISO week number

### Custom Scripts (`~/.bin/`)

| Script | Description |
|--------|-------------|
| `vscode-open` | Fast VS Code window switcher via AppleScript; falls back to `code` command |
| `gh-review-status` | GitHub PRs requesting review — formatted table or Starship indicator, 5min cache |
| `restic_backup` | Backblaze B2 backup via restic, credentials from Bitwarden CLI |
| `git-open` | Opens current repo's remote URL in browser |
| `md2pb` | Markdown → rich text on clipboard (Slack/Docs-ready) via pandoc |
| `concat-files` | Concatenate files with headers — useful for feeding to LLMs |
| `cursor-summarize` | Summarize Cursor AI chat exports via Claude, with content-hash caching |
| `decrypt_pdf` | Decrypt a password-protected PDF in-place via qpdf |
| `portainer.exs` | Elixir script to dump Portainer Docker stack configs |
| `wt` | Wrapper for custom `wt` project binary |

### Daily Note Quick-Access

One keystroke to land in today's daily note with a timestamp ready to type.

| Context | Keys | What happens |
|---------|------|-------------|
| Normal outer tmux | `C-Space N d` | Switches to Workbook, opens daily note, inserts `- HH:MM - ` |
| Nested/suspended tmux | `F11` | Resumes outer tmux, then same as above |
| Already in Workbook nvim | `<leader>wd` | Opens daily note (no timestamp) |

**Pieces:** tmux bindings (`tmux.conf`) → `~/.bin/tmux-daily-note` (script) → `:Daily` nvim command (Workbook `.nvim.lua`)

## Repository Structure

```
~/.local/share/chezmoi/          # Source directory (this repo)
├── managed/                     # Files applied to home directory
│   ├── dot_bin/                # → ~/.bin/ (custom scripts)
│   ├── dot_config/
│   │   ├── ghostty/           # → ~/.config/ghostty/
│   │   ├── iterm2/            # → ~/.config/iterm2/
│   │   ├── nvim/              # → ~/.config/nvim/
│   │   ├── starship.toml      # → ~/.config/starship.toml
│   │   └── tmux/              # → ~/.config/tmux/
│   ├── Library/.../espanso/    # → ~/Library/.../espanso/ (macOS)
│   ├── dot_gitconfig.tmpl      # → ~/.gitconfig (templated)
│   ├── dot_gitconfig.local.tmpl # → ~/.gitconfig.local
│   ├── dot_gitignore           # → ~/.gitignore
│   ├── dot_zshrc.tmpl          # → ~/.zshrc (templated)
│   └── run_onchange_*.sh.tmpl  # Scripts run when content changes
├── functions/                   # Zsh autoload functions (c, git-export, workbook)
├── wrappers/                    # Shell command wrappers (rm, ssh)
├── plugins/                     # Zsh plugins (per-project-history)
└── CLAUDE.md                    # AI assistant context

~/.config/chezmoi/               # Config directory (not in repo)
└── chezmoi.toml                 # Machine-specific configuration
```

**Note:** The `.chezmoiroot` file contains `managed`, making `managed/` the root for applied files. The `functions/`, `wrappers/`, and `plugins/` directories live outside `managed/` and are referenced by the zshrc template via `$DOTFILES_DIR`.

## Daily Usage

```bash
# Apply any pending changes
chezmoi apply

# Edit a managed file and auto-apply
chezmoi edit ~/.gitconfig

# Add a new file to chezmoi
chezmoi add ~/.newfile

# See what would change
chezmoi diff

# Update from git
cd ~/.local/share/chezmoi && git pull && chezmoi apply
```

## Raycast Integration

Add projects to `chezmoi.toml` to generate individual Raycast script commands. Each project gets its own script so you can assign custom hotkeys in Raycast.

```toml
[[data.raycast_projects]]
name = "Project Name"              # Display name in Raycast
path = "~/Sourcecode/project"      # Full path to project directory

[[data.raycast_projects]]
name = "Another Project"
path = "~/Sourcecode/another"
```

**How it works:**
- Scripts are generated at `~/.raycast/scripts/projects/open-<project-name>.sh`
- Uses the `vscode-open` helper for fast window switching (< 0.5s vs ~1.7s)
- If VS Code window already open for the project, switches to it instantly via AppleScript
- Otherwise falls back to standard `code` command
- Automatically regenerates when you modify the project list
- Obsolete scripts are automatically removed when projects are deleted
- Scripts appear in Raycast and can be assigned individual hotkeys

After adding projects, run:
```bash
chezmoi apply
```

Then in Raycast, search for "Open <Project Name>" and assign hotkeys.
