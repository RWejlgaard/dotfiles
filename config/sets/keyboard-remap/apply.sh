#!/bin/bash
set -euo pipefail

# Installs keyd (if missing) and points it at a config that remaps:
#   - Caps Lock to Escape
#   - Alt+C/Alt+V/Alt+R to Ctrl+C/Ctrl+V/Ctrl+R
# system-wide.
#
# This is evdev-level, below X11/Wayland and every desktop's own config
# backend, so it's a standalone set rather than something gnome/kde/xfce
# each apply themselves: it's the same remap regardless of desktop (and,
# unlike xfce's old setxkbmap-based approach, works the same under Wayland
# and even on a bare TTY), and machines without a desktop environment at all
# can still want it.

if ! command -v keyd >/dev/null 2>&1; then
    if [ -f /etc/arch-release ]; then
        sudo pacman -S --noconfirm keyd
    elif [ -f /etc/debian_version ]; then
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update && sudo apt install -y keyd
    elif [ -f /etc/alpine-release ]; then
        sudo apk add keyd
    elif [ -f /etc/redhat-release ]; then
        sudo dnf install -y keyd
    elif [ -f /etc/gentoo-release ]; then
        sudo emerge app-misc/keyd
    else
        echo "Warning: don't know how to install keyd on this system; install it manually." >&2
        exit 0
    fi
fi

sudo mkdir -p /etc/keyd
sudo tee /etc/keyd/dotfiles.conf >/dev/null <<'EOF'
[ids]
*

[main]
capslock = esc

[alt]
c = C-c
v = C-v
r = C-r
EOF

sudo systemctl enable --now keyd >/dev/null 2>&1 || true
sudo keyd reload || true
