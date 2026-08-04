#!/bin/bash
set -e # exit on error

fish_path="$(command -v fish)"

# ensure fish is in shells
if ! grep -q "$fish_path" /etc/shells; then
    echo "$fish_path" | sudo tee -a /etc/shells
fi

# change shell to fish
if ! [ "$(basename "$SHELL")" == "fish" ]; then
    chsh -s "$fish_path"
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

# Arch specific: keep the local package database fresh via an hourly cron job
if [ -f /etc/arch-release ]; then
    user="$(id -un)"

    # enable & start the cron daemon (cronie was installed in 01-install-packages.sh).
    # Skip if systemd isn't actually running, e.g. inside a container build.
    if [ -d /run/systemd/system ]; then
        sudo systemctl enable --now cronie.service
    fi

    # cron runs the job non-interactively, so the invoking user needs
    # passwordless sudo for it to be able to run pacman unattended
    if [ "$EUID" -ne 0 ]; then
        sudoers_file="/etc/sudoers.d/99-$user-nopasswd"
        sudoers_tmp="$(mktemp)"
        echo "$user ALL=(ALL) NOPASSWD: ALL" > "$sudoers_tmp"
        sudo visudo -cf "$sudoers_tmp"
        sudo install -m 440 "$sudoers_tmp" "$sudoers_file"
        rm -f "$sudoers_tmp"
    fi

    # install/refresh the hourly job, replacing any previous copy of it
    cron_cmd="sudo pacman -Syy"
    cron_line="0 * * * * $cron_cmd"
    existing_cron="$(crontab -l 2>/dev/null | grep -vF "$cron_cmd" || true)"
    printf '%s\n%s\n' "$existing_cron" "$cron_line" | crontab -
fi
