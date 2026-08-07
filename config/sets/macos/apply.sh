#!/bin/bash
set -euo pipefail

# Sets the macOS keyboard repeat rate as fast as possible and the initial
# repeat delay as short as possible — below the range the System Settings
# slider exposes. Log out/in (or restart affected apps) for it to fully
# take effect everywhere.

if [ "$(uname)" != "Darwin" ] || ! command -v defaults >/dev/null 2>&1; then
    echo "Warning: not macOS (or 'defaults' unavailable); skipping keyboard repeat settings." >&2
    exit 0
fi

defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10
