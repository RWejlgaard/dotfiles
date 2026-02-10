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

# Gentoo specific kernel script
if [ -f /etc/gentoo-release ]; then
    init_system=openrc
    echo "Gentoo detected, need clarification on which init system is used."
    echo -e "Which init system?\n\n1> openrc\n2> systemd"
    read -p "[1]/2: " -n 1;
    echo
    if [ "$REPLY" == "2" ]; then
        init_system=systemd
    fi

    sudo cp scripts/gentoo-kernel-upgrade-$init_system /usr/bin/gentoo-kernel-upgrade

fi