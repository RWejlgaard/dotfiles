#!/bin/bash

# ensure fish is in shells
if ! grep -q "$(which fish)" /etc/shells; then
    echo "$(which fish)" | sudo tee -a /etc/shells
fi

# change shell to fish
chsh -s $(which fish)
