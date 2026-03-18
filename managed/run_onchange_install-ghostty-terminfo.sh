#!/bin/bash
# Install Ghostty terminfo so tmux (and other tools) can identify
# Ghostty's capabilities (mouse, clipboard, etc.)
#
# On macOS: copies from the Ghostty app bundle
# On Linux: uses ghostty +show-config if available, otherwise skips

set -eu

if infocmp xterm-ghostty >/dev/null 2>&1; then
  exit 0
fi

echo "Installing xterm-ghostty terminfo..."

# macOS: copy compiled terminfo from app bundle
if [[ "$(uname)" == "Darwin" ]]; then
  src="/Applications/Ghostty.app/Contents/Resources/terminfo"
  if [[ -d "$src" ]]; then
    mkdir -p ~/.terminfo/78
    cp "$src/78/xterm-ghostty" ~/.terminfo/78/
    echo "Installed from Ghostty.app bundle"
    exit 0
  fi
fi

# Linux/fallback: compile from ghostty CLI if available
if command -v ghostty >/dev/null 2>&1; then
  ghostty +list-terminfo | tic -x -o ~/.terminfo - 2>/dev/null
  echo "Installed via ghostty +list-terminfo"
  exit 0
fi

echo "Ghostty not found, skipping terminfo install"
