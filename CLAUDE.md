# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a chezmoi dotfiles repository that manages Stuart's (Stu's) shell configuration, git settings, custom scripts, and other dotfiles across machines.

**Key Concept**: This repository uses chezmoi's source state format. Files are stored with special prefixes that chezmoi interprets when applying:
- `dot_` prefix becomes `.` (e.g., `dot_gitconfig` → `~/.gitconfig`)
- `executable_` makes files executable (e.g., `executable_restic_backup` → executable script)
- `.tmpl` suffix indicates chezmoi templates with variable substitution
- `run_onchange_` scripts execute when their content changes

The actual dotfiles live in `~/.local/share/chezmoi` (source state) and are applied to the home directory (`~`) via chezmoi.

## Directory Structure

```
.
├── managed/              # All files that chezmoi applies (source state)
│   ├── dot_bin/         # Custom executable scripts → ~/.bin/
│   ├── dot_config/      # Config files → ~/.config/
│   ├── dot_gitconfig    # Git configuration → ~/.gitconfig
│   ├── dot_gitconfig.local.tmpl  # Machine-specific git config template
│   ├── dot_gitignore    # Global gitignore → ~/.gitignore
│   ├── dot_zshrc.tmpl   # Zsh configuration template → ~/.zshrc
│   └── run_onchange_generate-raycast-scripts.sh.tmpl  # Auto-generates Raycast scripts
└── functions/           # Zsh autoload functions loaded via fpath
    ├── c                # Quick project navigation (cd $PROJECTS/$1)
    └── _c               # Completion for c function
```

## Common Commands

### Managing Dotfiles
```bash
# Apply changes to home directory
chezmoi apply

# Apply and show what changed
chezmoi apply -v

# Edit a managed file in your editor and auto-apply
chezmoi edit ~/.gitconfig

# Add a new file to chezmoi management
chezmoi add ~/.newfile

# See what would change without applying
chezmoi diff

# Re-run all run_onchange_ scripts
chezmoi apply --force

# Check for issues
chezmoi doctor
```

### Development Workflow
```bash
# Edit files directly in source state
cd ~/.local/share/chezmoi

# After making changes, apply them
chezmoi apply

# Commit changes (from this directory)
git add -A
git commit -m "Description of changes"
git push
```

## Architecture

### Template System
Files ending in `.tmpl` use Go templates for dynamic content:
- `{{ .chezmoi.workingTree }}` - Path to chezmoi source directory
- `{{ .fullName }}`, `{{ .email }}` - User data (from `.chezmoidata.yaml` or chezmoi config)
- `{{ .projectDir }}` - Projects directory path
- `{{ .raycast_projects }}` - Array of Raycast project shortcuts

### Zsh Configuration Flow
1. `dot_zshrc.tmpl` is applied as `~/.zshrc`
2. Sets `DOTFILES_DIR` to chezmoi working tree
3. Adds `functions/` directory to `fpath` for autoloading
4. Autoloads all functions from `functions/`
5. Initializes completion, starship prompt, zoxide, and fzf

### Custom Functions
The `functions/` directory contains Zsh autoload functions:
- `c` - Quick navigation to projects: `c <project-name>` → `cd $PROJECTS/<project-name>`
- Completion support via `_c` function

### Key Scripts in dot_bin/

**vscode-open** - Fast VS Code window switcher
- Switches to existing VS Code window if project already open (< 0.5s)
- Falls back to `code` command if window not found (~1.7s)
- Uses AppleScript to find windows by project name
- Usage: `vscode-open <project-path> [project-name]`
- Used by Raycast project scripts for instant window switching

**gh-review-status** - GitHub PR review tracker
- Shows PRs requesting review in formatted table or Starship status
- Caches PR data for 5 minutes to avoid API rate limits
- Commands: `list` (default), `status` (for Starship), `update` (force refresh)
- Usage: `gh-review-status` or `gh-review-status --quiet` (background update)

**restic_backup** - Backblaze B2 backup via restic
- Backs up `~/Sourcecode`, `~/.local/share/chezmoi`, `~/.config`, `~/.private`, documents, pictures
- Retrieves credentials from `rbw` (Bitwarden CLI)
- Usage: `restic_backup` or `source restic_backup export` (export env vars only)

**run_onchange_generate-raycast-scripts.sh** - Raycast integration
- Auto-generates Raycast script commands from `.chezmoidata.yaml` project list
- Runs automatically when the script or data file changes
- Creates scripts in `~/.raycast/scripts/` for quick project opening

## Git Configuration

The repository includes comprehensive git configuration with:
- Default branch: `main`
- Pull strategy: fast-forward only (`pull.ff = only`)
- Automatic rebase features: `autoStash`, `autoSquash`, `updateRefs`
- Better diff algorithm: `histogram` with `zdiff3` conflict style
- Automatic pruning of deleted remote branches and tags
- Branch sorting by most recent commit

## Important Notes

- **Never commit `.context/`** - Listed in user instructions, should be in `.chezmoiignore`
- The `.chezmoiroot` file contains `managed`, making `managed/` the root for applied files
- Template variables come from either chezmoi's config file or `.chezmoidata.yaml` (referenced in run_onchange script but not in repo)
- Functions in `functions/` must follow Zsh autoload conventions (function name matches filename)
- The `c` function depends on `$PROJECTS` being set in the environment
