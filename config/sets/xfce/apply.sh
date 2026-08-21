#!/bin/bash
set -euo pipefail

# XFCE settings that diverge from stock defaults on this machine, mirroring
# config/sets/kde/apply.sh and config/sets/gnome/apply.sh's choices for the
# XFCE desktop.
# Each section below is independent and safe to re-run.
#
# The "# intent:" markers below tie each section to an entry in
# config/desktop-common.sh, which is the one place the kde/gnome/xfce sets
# agree on what they're all supposed to cover.

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
# shellcheck source=config/desktop-common.sh
source "$REPO/config/desktop-common.sh"

if ! command -v xfconf-query >/dev/null 2>&1; then
    echo "Warning: xfconf-query not found (not an XFCE system?); skipping XFCE settings." >&2
    exit 0
fi

# Sets a property, creating it (and its channel) if it doesn't exist yet.
# xfconf channels aren't pre-registered, so writing to one that belongs to an
# uninstalled component (e.g. xfce4-power-manager) isn't an error — it just
# sits inert until/unless that component is installed. The sections below
# still gate on the owning binary where one isn't part of a base XFCE
# install, so the warnings stay meaningful.
xset_prop() {
    xfconf-query -c "$1" -p "$2" -n -t "$3" -s "$4"
}

# --- Keyboard ---------------------------------------------------------

# intent: keyboard-repeat
# Settings > Keyboard > Behaviour.
xset_prop keyboards /Default/KeyRepeat bool true
xset_prop keyboards /Default/KeyRepeat/Rate int "$KEY_REPEAT_RATE"
xset_prop keyboards /Default/KeyRepeat/Delay int "$KEY_REPEAT_DELAY_MS"

# Apply immediately in the current X11 session; a fresh login also
# re-applies it from the "keyboards" channel either way.
if [ -n "${DISPLAY:-}" ] && command -v xset >/dev/null 2>&1; then
    xset r rate "$KEY_REPEAT_DELAY_MS" "$KEY_REPEAT_RATE" || true
fi

# intent: caps-as-escape
# Unlike the layout/group/compose-key options,
# xfsettingsd has no xfconf-backed setting for this XKB option group, so it
# can't be stored declaratively the way the kde/gnome sets do it — it's
# applied directly via setxkbmap instead, both now and on every future
# login via an autostart entry.
if [ -n "${DISPLAY:-}" ] && command -v setxkbmap >/dev/null 2>&1; then
    setxkbmap -option caps:escape || true
fi
if command -v setxkbmap >/dev/null 2>&1; then
    mkdir -p ~/.config/autostart
    cat > ~/.config/autostart/caps-escape.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Caps Lock as Escape
Exec=sh -c "sleep 2 && setxkbmap -option caps:escape"
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOF
fi

# intent: alt-cvr-as-ctrl-cvr
# Evdev-level, via keyd; see install_alt_cvr_remap in desktop-common.sh.
install_alt_cvr_remap

# --- Screen locking & power --------------------------------------------

# intent: no-screen-lock
# Settings > Screensaver. xfce4-screensaver
# is a separate, optional package (older XFCE releases use light-locker
# instead, which has no xfconf-backed settings of its own).
if command -v xfce4-screensaver >/dev/null 2>&1; then
    xset_prop xfce4-screensaver /saver/idle-activation-enabled bool false
    xset_prop xfce4-screensaver /lock/enabled bool false
else
    echo "Warning: xfce4-screensaver not found; skipping screen lock settings." >&2
fi

# intent: no-idle-display
# Never dim or turn off the display when idle, on AC or battery, and don't
# lock on suspend/hibernate (Settings > Power Manager).
if command -v xfce4-power-manager >/dev/null 2>&1; then
    xset_prop xfce4-power-manager /xfce4-power-manager/blank-on-ac int 0
    xset_prop xfce4-power-manager /xfce4-power-manager/blank-on-battery int 0
    xset_prop xfce4-power-manager /xfce4-power-manager/dpms-enabled bool false
    xset_prop xfce4-power-manager /xfce4-power-manager/lock-screen-suspend-hibernate bool false
else
    echo "Warning: xfce4-power-manager not found; skipping power settings." >&2
fi

# --- Device automount ----------------------------------------------------

# intent: no-automount
# Settings > Removable Drives and Media. thunar-volman is a separate,
# optional package from Thunar itself.
if command -v thunar-volman >/dev/null 2>&1; then
    xset_prop thunar-volman /autobrowse/enabled bool false
    xset_prop thunar-volman /automount-drives/enabled bool false
    xset_prop thunar-volman /automount-media/enabled bool false
    xset_prop thunar-volman /autoopen/enabled bool false
else
    echo "Warning: thunar-volman not found; skipping automount settings." >&2
fi

# --- File manager / dialogs ----------------------------------------------

# intent: editable-path-bar
# Thunar: use an editable path bar instead of breadcrumbs.
if command -v thunar >/dev/null 2>&1; then
    xset_prop thunar /last-location-bar string ThunarLocationEntry
else
    echo "Warning: thunar not found; skipping Thunar settings." >&2
fi

# GTK file open/save dialogs: same GSettings keys as config/sets/gnome, since
# they're read by any GTK app regardless of desktop environment.
if command -v gsettings >/dev/null 2>&1; then
    gset() {
        local schema="$1" key="$2" value="$3"
        if gsettings list-schemas | grep -qxF "$schema"; then
            gsettings set "$schema" "$key" "$value"
        else
            echo "Warning: schema '$schema' not found; skipping $schema $key." >&2
        fi
    }
    gset org.gtk.Settings.FileChooser location-mode filename-entry
    gset org.gtk.gtk4.Settings.FileChooser location-mode filename-entry
fi

# --- Appearance ------------------------------------------------------------

# intent: dark-theme
# Prefer a dark GTK + window manager theme, whichever of these common dark
# themes is actually installed (Settings > Appearance / Window Manager).
pick_dark_theme() {
    local name base
    for name in Greybird-dark Arc-Dark Adapta-Nokto Materia-dark Adwaita-dark; do
        for base in /usr/share/themes "$HOME/.themes"; do
            if [ -d "$base/$name/gtk-3.0" ]; then
                echo "$name"
                return 0
            fi
        done
    done
    return 1
}

if dark_theme="$(pick_dark_theme)"; then
    xset_prop xsettings /Net/ThemeName string "$dark_theme"
    if [ -d "/usr/share/themes/$dark_theme/xfwm4" ] || [ -d "$HOME/.themes/$dark_theme/xfwm4" ]; then
        xset_prop xfwm4 /general/theme string "$dark_theme"
    fi
else
    echo "Warning: no known dark theme (Greybird-dark/Arc-Dark/Adapta-Nokto/Materia-dark/Adwaita-dark) installed; skipping dark theme." >&2
fi

# --- Panel -------------------------------------------------------------

# Remove every panel but the first (XFCE's default layout ships a second,
# taskbar-style panel), and dock the one that's left to the bottom of the
# screen (Settings > Panel).
if xfconf-query -c xfce4-panel -p /panels >/dev/null 2>&1; then
    # A bare `-p` query on an array property prints a "Value is an array
    # with N items:" header and a blank line before the values, so filter
    # down to just the (numeric) panel/plugin ids.
    mapfile -t panel_ids < <(xfconf-query -c xfce4-panel -p /panels | grep -E '^[0-9]+$' | sort -n)

    if [ "${#panel_ids[@]}" -gt 0 ]; then
        primary="${panel_ids[0]}"

        for id in "${panel_ids[@]:1}"; do
            plugin_ids=$(xfconf-query -c xfce4-panel -p "/panels/panel-$id/plugin-ids" 2>/dev/null | grep -E '^[0-9]+$' || true)
            for plugin_id in $plugin_ids; do
                xfconf-query -c xfce4-panel -p "/plugins/plugin-$plugin_id" -r -R 2>/dev/null || true
            done
            xfconf-query -c xfce4-panel -p "/panels/panel-$id" -r -R 2>/dev/null || true
        done

        xfconf-query -c xfce4-panel -p /panels -t int -s "$primary" --force-array

        xfconf-query -c xfce4-panel -p "/panels/panel-$primary/position" -n -t string -s "p=12;x=0"
        xfconf-query -c xfce4-panel -p "/panels/panel-$primary/position-locked" -n -t bool -s true

        if [ -n "${DISPLAY:-}" ] && command -v xfce4-panel >/dev/null 2>&1; then
            xfce4-panel -r || true
        fi
    fi
else
    echo "Warning: xfce4-panel has no '/panels' property yet (never configured); skipping panel changes." >&2
fi

# --- Terminal --------------------------------------------------------------

# Install Kitty and make it the default terminal (Settings > Default
# Applications > Utilities), via ~/.config/xfce4/helpers.rc — the file
# XFCE's preferred-applications system reads/writes either way.
install_kitty() {
    command -v kitty >/dev/null 2>&1 && return 0

    if [ -f /etc/arch-release ]; then
        sudo pacman -S --noconfirm kitty
    elif [ -f /etc/debian_version ]; then
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update && sudo apt install -y kitty
    elif [ -f /etc/alpine-release ]; then
        sudo apk add kitty
    elif [ -f /etc/redhat-release ]; then
        sudo dnf install -y kitty
    elif [ -f /etc/gentoo-release ]; then
        sudo emerge x11-terms/kitty
    else
        echo "Warning: don't know how to install kitty on this system; install it manually." >&2
        return 1
    fi
}

if install_kitty; then
    mkdir -p ~/.config/xfce4
    helpers_rc=~/.config/xfce4/helpers.rc
    if [ -f "$helpers_rc" ] && grep -q '^TerminalEmulator=' "$helpers_rc"; then
        sed -i 's/^TerminalEmulator=.*/TerminalEmulator=kitty/' "$helpers_rc"
    else
        printf 'TerminalEmulator=kitty\n' >> "$helpers_rc"
    fi
fi
