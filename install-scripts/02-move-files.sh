#!/bin/bash
set -euo pipefail # exit on error, unset vars, and failed pipes

# Symlink tracked config files into place so edits to the live config flow
# straight back to the repo (no more "tweaked it and lost it on refresh").
# Resolve the repo root so this works regardless of where it's invoked from.
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Symlink SRC -> DEST, but back up any pre-existing *real* file (not a symlink)
# to DEST.bak first so a fresh-machine install never clobbers existing configs.
link() {
    local src="$1" dest="$2"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Backing up existing $dest -> $dest.bak"
        mv "$dest" "$dest.bak"
    fi
    ln -sf "$src" "$dest"
}

# create directories
mkdir -p ~/.config/nvim
mkdir -p ~/.config/fish
mkdir -p ~/.config/fish/conf.d

# vim
link "$REPO/config/vim/init.lua" ~/.config/nvim/init.lua

# fish
link "$REPO/config/fish/config.fish" ~/.config/fish/config.fish
link "$REPO/config/fish/aliases.fish" ~/.config/fish/conf.d/aliases.fish
link "$REPO/config/fish/functions.fish" ~/.config/fish/conf.d/functions.fish

# Only copy envvars.fish if it doesn't exist.
# This way we can override it with our own per-machine config.
if [ ! -f ~/.config/fish/conf.d/envvars.fish ]; then
    cp "$REPO/config/fish/envvars.fish" ~/.config/fish/conf.d/
fi

# tmux
link "$REPO/config/tmux/tmux.conf" ~/.tmux.conf
mkdir -p ~/.tmux/scripts
for script in "$REPO"/config/tmux/scripts/*.sh; do
    link "$script" ~/.tmux/scripts/"$(basename "$script")"
done
# only copy status.conf if it doesn't exist, so local customizations are preserved
if [ ! -f ~/.tmux/scripts/status.conf ]; then
    cp "$REPO/config/tmux/scripts/status.conf" ~/.tmux/scripts/
fi
