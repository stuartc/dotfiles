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

4. **Optional: Add Raycast projects** (see below)

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

### Optional: Raycast Project Shortcuts

Add projects to generate individual Raycast script commands. Each project gets its own script so you can assign custom hotkeys in Raycast.

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

## Repository Structure

```
~/.local/share/chezmoi/          # Source directory (this repo)
├── managed/                     # Files applied to home directory
│   ├── dot_bin/                # → ~/.bin/ (custom scripts)
│   ├── dot_config/             # → ~/.config/ (config files)
│   ├── dot_gitconfig           # → ~/.gitconfig
│   ├── dot_zshrc.tmpl          # → ~/.zshrc (templated)
│   └── run_onchange_*.sh.tmpl  # Scripts run when content changes
└── functions/                   # Zsh autoload functions

~/.config/chezmoi/               # Config directory (not in repo)
└── chezmoi.toml                 # Machine-specific configuration
```

**Note:** The `.chezmoiroot` file contains `managed`, making `managed/` the root for applied files.