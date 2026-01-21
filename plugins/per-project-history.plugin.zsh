#!/usr/bin/env zsh
#
# per-project-history - Prioritize project-specific command history in Zsh
#
# ORIGINS
# -------
# This plugin is a modified version of Ivan Cukic's per-project-history:
#   https://github.com/ivan-cukic/zsh-per-project-history
#
# Which itself is based on Jim Hester's original per-directory-history:
#   https://github.com/jimhester/per-directory-history
#
# WHAT'S DIFFERENT IN THIS VERSION
# ---------------------------------
# The original plugins use a toggle (Ctrl+G) to switch between project-only
# OR global-only history. When viewing project history, global history is
# completely hidden, and vice versa.
#
# This version merges instead of isolates:
#   - Project history is loaded ON TOP of global history
#   - Up-arrow shows project commands first, then global commands below
#   - No toggle needed - you always have access to everything
#   - The Ctrl+G keybinding has been removed
#
# WHAT IT DOES
# ------------
# When you cd into a project directory, this plugin loads that project's
# command history on top of your global history. Press up-arrow and you'll
# see project-specific commands first, with global history still accessible
# below. No toggling required - it just works.
#
# Commands are saved to both global history AND project-specific history,
# so you never lose anything.
#
# HOW IT WORKS
# ------------
# 1. Zsh loads global history (~/.zsh_history) on startup as normal
# 2. When you cd into a project, the plugin detects it via marker files
# 3. Project history is loaded via `fc -R`, appending to the history list
# 4. Since up-arrow searches from newest to oldest, project commands appear first
# 5. HIST_IGNORE_ALL_DUPS removes duplicates, keeping the most recent entry
#
# INSTALLATION
# ------------
# Source this file in your .zshrc:
#
#   source /path/to/per-project-history.plugin.zsh
#
# For best results, ensure these options are set in your .zshrc:
#
#   setopt HIST_IGNORE_ALL_DUPS  # Remove older duplicates when new entry added
#   setopt SHARE_HISTORY         # Share history between terminal sessions
#   setopt EXTENDED_HISTORY      # Record timestamp with each command
#
# CONFIGURATION
# -------------
# Set these variables BEFORE sourcing the plugin:
#
#   HISTORY_BASE (default: ~/.zsh_project_history)
#     Base directory where project histories are stored.
#     Each project gets a subdirectory matching its path.
#
#   PER_PROJECT_HISTORY_TAGS (default: see below)
#     Array of marker files/directories that identify a project root.
#     Default: (.git .hg .jj .stack-work .cabal .cargo .envrc .per_project_history)
#
# Example custom configuration:
#
#   export HISTORY_BASE="$HOME/.local/share/zsh_project_history"
#   export PER_PROJECT_HISTORY_TAGS=(.git .hg package.json Makefile)
#   source /path/to/per-project-history.plugin.zsh
#
# PROJECT DETECTION
# -----------------
# A directory is considered a project root if it contains any of the marker
# files/directories listed in PER_PROJECT_HISTORY_TAGS. The plugin searches
# upward from the current directory until it finds a match or reaches /.
#
# To force any directory to be a project root, create an empty file:
#   touch /path/to/my/directory/.per_project_history
#
# HISTORY STORAGE
# ---------------
# Project histories are stored at:
#   $HISTORY_BASE/<absolute-project-path>/history
#
# For example, if HISTORY_BASE=~/.zsh_project_history and your project is at
# ~/code/myproject, the history file will be:
#   ~/.zsh_project_history/Users/you/code/myproject/history
#
# LICENSE
# -------
# Copyright (c) 2014 Jim Hester
# Copyright (c) 2025 Ivan Cukic
#
# This software is provided 'as-is', without any express or implied warranty.
# In no event will the authors be held liable for any damages arising from the
# use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not claim
#    that you wrote the original software. If you use this software in a product,
#    an acknowledgment in the product documentation would be appreciated but is
#    not required.
#
# 2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
#
# 3. This notice may not be removed or altered from any source distribution.
#
################################################################################

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------

[[ -z $HISTORY_BASE ]] && HISTORY_BASE="$HOME/.zsh_project_history"

if [[ -z "${PER_PROJECT_HISTORY_TAGS}" ]]; then
  declare -a PER_PROJECT_HISTORY_TAGS
  export PER_PROJECT_HISTORY_TAGS=(.git .hg .jj .stack-work .cabal .cargo .envrc .per_project_history)
  declare -r PER_PROJECT_HISTORY_TAGS
fi

#-------------------------------------------------------------------------------
# implementation details
#-------------------------------------------------------------------------------

_per_project_history_directory="$HISTORY_BASE${PWD:A}/history"

export ZSH_PROJECT_HISTORY_ACTIVE_DIRECTORY=""

function _per-project-history-directory-tagged() {
  TESTING_DIRECTORY="$1"
  for TAG in ${PER_PROJECT_HISTORY_TAGS}; do
    if [[ -e "${TESTING_DIRECTORY}/${TAG}" ]]; then
      return 0
    fi
  done
  return 1
}

function _per-project-history-find-up() {
  CURRENT_DIR="${PWD}"

  while
    _per-project-history-directory-tagged "${CURRENT_DIR}"
    [ $? -ne 0 ]
  do
    CURRENT_DIR="${CURRENT_DIR:h}"
    if [[ "/" = ${CURRENT_DIR} ]]; then
      echo "/"
      return 1
    fi
  done

  echo "${CURRENT_DIR}"
}

function _per-project-history-change-directory() {
  local CURRENT_PROJECT_DIRECTORY=$(_per-project-history-find-up)
  if [[ ${CURRENT_PROJECT_DIRECTORY} = "/" ]]; then
    CURRENT_PROJECT_DIRECTORY="/no_active_project"
  fi

  if [[ "${ZSH_PROJECT_HISTORY_ACTIVE_DIRECTORY}" != "${CURRENT_PROJECT_DIRECTORY}" ]]; then
    _per-project-history-change-directory-impl "${ZSH_PROJECT_HISTORY_ACTIVE_DIRECTORY}" "${CURRENT_PROJECT_DIRECTORY}"
    ZSH_PROJECT_HISTORY_ACTIVE_DIRECTORY="${CURRENT_PROJECT_DIRECTORY}"
  fi
}

function _per-project-history-change-directory-impl() {
  OLD_PROJECT_DIR="$1"
  NEW_PROJECT_DIR="$2"
  _per_project_history_directory="$HISTORY_BASE${NEW_PROJECT_DIR:A}/history"
  mkdir -p ${_per_project_history_directory:h}

  # Save to global history
  fc -AI $HISTFILE

  # Save to previous project history if we were in a project
  if [[ -n "$OLD_PROJECT_DIR" && "$OLD_PROJECT_DIR" != "/no_active_project" ]]; then
    local prev="$HISTORY_BASE${OLD_PROJECT_DIR:A}/history"
    mkdir -p ${prev:h}
    fc -AI $prev
  fi

  # Load new project history on top of existing history
  # fc -R appends to end of history list, making these entries "most recent"
  # HIST_IGNORE_ALL_DUPS removes older duplicates, keeping the newer ones
  if [[ -e $_per_project_history_directory ]]; then
    fc -R $_per_project_history_directory
  fi
}

function _per-project-history-addhistory() {
  # respect hist_ignore_space
  if [[ -o hist_ignore_space ]] && [[ "$1" == \ * ]]; then
      true
  else
      print -Sr -- "${1%%$'\n'}"
      # instantly write history if set options require it.
      if [[ -o share_history ]] || \
         [[ -o inc_append_history ]] || \
         [[ -o inc_append_history_time ]]; then
          fc -AI $HISTFILE
          fc -AI $_per_project_history_directory
      fi
      fc -p $_per_project_history_directory
  fi
}

function _per-project-history-precmd() {
  if [[ $_per_project_history_initialized == false ]]; then
    _per_project_history_initialized=true
    # Layer project history on top of already-loaded global history
    _per-project-history-change-directory
  fi
}

mkdir -p ${_per_project_history_directory:h}

#add functions to the exec list for chpwd and zshaddhistory
autoload -U add-zsh-hook
add-zsh-hook chpwd _per-project-history-change-directory
add-zsh-hook zshaddhistory _per-project-history-addhistory
add-zsh-hook precmd _per-project-history-precmd

# set initialized flag to false
_per_project_history_initialized=false
