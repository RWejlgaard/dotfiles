#!/bin/bash
set -e # exit on error

# vim
mkdir -p ~/.config/nvim
cp init.lua ~/.config/nvim/

# fish
mkdir -p ~/.config/fish
cp config.fish ~/.config/fish/

# tmux
cp tmux.conf ~/.tmux.conf