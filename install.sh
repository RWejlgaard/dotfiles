#!/bin/bash
set -e # exit on error

# tmux config
cp tmux.conf ~/.tmux.conf

# install tmux package manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# install tmux packages
#./.tmux/plugins/tpm/bin/install_plugins

# vim config
mkdir -p ~/.config/nvim
cp init.vim plug.vim ~/.config/nvim/

# fish config
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
cp config.fish ~/.config/fish/

# install fish plugins
fish -c 'omf install bobthefish bang-bang fzf'
