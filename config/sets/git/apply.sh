#!/bin/bash
set -euo pipefail

# Installs Delta (a syntax-highlighting pager for git diff/show/log) and
# wires it in, mirroring config/sets/xfce/apply.sh's install_kitty. Skipped
# gracefully if this system's package manager doesn't have it (or isn't
# recognized) — the rest of the git set's aliases/config still apply either
# way, just with git's default (uncolored) pager.

# Deliberately not `git config --global`: when ~/.gitconfig doesn't exist,
# that resolves to ~/.config/git/config — the *symlink back into this repo*
# — and would silently rewrite the tracked gitconfig file instead of local,
# per-machine state. `--file` pins the write to a separate, untracked file
# that gitconfig includes; a missing include target is a silent no-op, so
# this is safe to skip entirely when delta isn't available.
GIT_LOCAL_CONFIG=~/.config/git/local

install_delta() {
    command -v delta >/dev/null 2>&1 && return 0

    if [ "$(uname)" == "Darwin" ]; then
        command -v brew >/dev/null 2>&1 && brew install git-delta
    elif [ "$(uname)" == "FreeBSD" ]; then
        sudo pkg install -y git-delta
    elif [ -f /etc/arch-release ]; then
        sudo pacman -S --noconfirm git-delta
    elif [ -f /etc/debian_version ]; then
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update && sudo apt install -y git-delta
    elif [ -f /etc/alpine-release ]; then
        sudo apk add delta
    elif [ -f /etc/redhat-release ]; then
        sudo dnf install -y git-delta
    elif [ -f /etc/gentoo-release ]; then
        sudo emerge dev-util/git-delta
    else
        echo "Warning: don't know how to install delta on this system; install it manually." >&2
        return 1
    fi
}

if install_delta && command -v delta >/dev/null 2>&1; then
    git config --file "$GIT_LOCAL_CONFIG" core.pager "delta"
    git config --file "$GIT_LOCAL_CONFIG" interactive.diffFilter "delta --color-only"
    git config --file "$GIT_LOCAL_CONFIG" delta.navigate true

    # Line numbers, off by default. Also overrides delta's default
    # file-style and line-numbers-{left,right}-style, both plain ANSI
    # "blue" — poor contrast on a dark background (`delta --show-config`
    # shows every other default style resolved to a specific RGB/256-color
    # value; these two are the only ones left at a raw, unadjusted ANSI name).
    git config --file "$GIT_LOCAL_CONFIG" delta.line-numbers true
    git config --file "$GIT_LOCAL_CONFIG" delta.file-style "bold yellow ul"
    git config --file "$GIT_LOCAL_CONFIG" delta.line-numbers-left-style "white"
    git config --file "$GIT_LOCAL_CONFIG" delta.line-numbers-right-style "white"
else
    echo "Warning: delta not available; leaving git's default pager in place." >&2
fi
