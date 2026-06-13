#!/bin/bash
set -e # exit on error

# Symlink tracked config files into place so edits to the live config flow
# straight back to the repo (no more "tweaked it and lost it on refresh").
# Resolve the repo root so this works regardless of where it's invoked from.
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# create directories
mkdir -p ~/.config/nvim
mkdir -p ~/.config/fish
mkdir -p ~/.config/fish/conf.d

# vim
ln -sf "$REPO/config/vim/init.lua" ~/.config/nvim/init.lua

# fish
ln -sf "$REPO/config/fish/config.fish" ~/.config/fish/config.fish
ln -sf "$REPO/config/fish/aliases.fish" ~/.config/fish/conf.d/aliases.fish
ln -sf "$REPO/config/fish/functions.fish" ~/.config/fish/conf.d/functions.fish

# Only copy envvars.fish if it doesn't exist.
# This way we can override it with our own per-machine config.
if [ ! -f ~/.config/fish/conf.d/envvars.fish ]; then
    cp "$REPO/config/fish/envvars.fish" ~/.config/fish/conf.d/
fi

# tmux
ln -sf "$REPO/config/tmux/tmux.conf" ~/.tmux.conf
mkdir -p ~/.tmux/scripts
for script in "$REPO"/config/tmux/scripts/*.sh; do
    ln -sf "$script" ~/.tmux/scripts/
done
# only copy status.conf if it doesn't exist, so local customizations are preserved
if [ ! -f ~/.tmux/scripts/status.conf ]; then
    cp "$REPO/config/tmux/scripts/status.conf" ~/.tmux/scripts/
fi
