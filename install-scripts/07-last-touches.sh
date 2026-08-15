#!/bin/bash
set -e # exit on error

fish_path="$(command -v fish)"

# ensure fish is in shells
if ! grep -q "$fish_path" /etc/shells; then
    echo "$fish_path" | sudo tee -a /etc/shells
fi

# change shell to fish
# (via sudo + explicit user: plain `chsh` re-authenticates as the invoking
# user even when they already have sudo rights, which hangs non-interactive
# installs; root can change any user's shell without a further password)
if ! [ "$(basename "$SHELL")" == "fish" ]; then
    sudo chsh -s "$fish_path" "$(id -un)"
fi

# create local bin directory
mkdir -p ~/bin

# Gentoo specific kernel script. It works out for itself whether this
# system's kernel images are named vmlinuz-<version> or kernel-<version>, so
# there's nothing to ask about here.
if [ -f /etc/gentoo-release ]; then
    sudo cp scripts/gentoo-kernel-upgrade /usr/bin/gentoo-kernel-upgrade
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
