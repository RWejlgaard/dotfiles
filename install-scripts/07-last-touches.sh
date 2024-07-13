#!/bin/bash

# ensure fish is in shells
if ! grep -q "$(which fish)" /etc/shells; then
    echo "$(which fish)" | sudo tee -a /etc/shells
fi

# change shell to fish
if ! [ "$(basename $SHELL)" == "fish" ]; then
    chsh -s $(which fish)
fi

# create local bin directory
mkdir -p ~/bin