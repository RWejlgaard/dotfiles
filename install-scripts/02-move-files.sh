#!/bin/bash
set -e # exit on error

# create directories
mkdir -p ~/.config/nvim
mkdir -p ~/.config/fish
mkdir -p ~/.config/fish/conf.d

# vim
cp config/vim/init.lua ~/.config/nvim/

# fish
cp config/fish/config.fish ~/.config/fish/
cp config/fish/aliases.fish ~/.config/fish/conf.d/
cp config/fish/functions.fish ~/.config/fish/conf.d/

# Only copy envvars.fish if it doesn't exist.
# This way we can override it with our own configs.
if [ ! -f ~/.config/fish/conf.d/envvars.fish ]; then
    cp config/fish/envvars.fish ~/.config/fish/conf.d/
fi

# tmux
cp config/tmux/tmux.conf ~/.tmux.conf
