#!/bin/bash
set -e # exit on error

# create directories
mkdir -p ~/.config/nvim
mkdir -p ~/.config/fish
mkdir -p ~/.config/fish/conf.d

# vim
cp init.lua ~/.config/nvim/

# fish
cp config.fish ~/.config/fish/

# if envvars doesn't exist, copy it
if [ ! -f ~/.config/fish/conf.d/envvars.fish ]; then
    cp envvars.fish ~/.config/fish/conf.d/
fi

# tmux
cp tmux.conf ~/.tmux.conf
