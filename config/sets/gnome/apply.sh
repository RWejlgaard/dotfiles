#!/bin/bash
set -euo pipefail

# GNOME settings that diverge from stock defaults on this machine, mirroring
# config/sets/kde/apply.sh's choices for the GNOME desktop.
# Each section below is independent and safe to re-run.
#
# The "# intent:" markers below tie each section to an entry in
# config/desktop-common.sh, which is the one place the kde/gnome/xfce sets
# agree on what they're all supposed to cover.

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
# shellcheck source=config/desktop-common.sh
source "$REPO/config/desktop-common.sh"

if ! command -v gsettings >/dev/null 2>&1; then
    echo "Warning: gsettings not found (not a GNOME system?); skipping GNOME settings." >&2
    exit 0
fi

# Only set a key if its schema is actually installed, so a partial GNOME
# install (e.g. missing gnome-settings-daemon) doesn't abort the whole set.
gset() {
    local schema="$1" key="$2" value="$3"
    if gsettings list-schemas | grep -qxF "$schema"; then
        gsettings set "$schema" "$key" "$value"
    else
        echo "Warning: schema '$schema' not found; skipping $schema $key." >&2
    fi
}

# intent: keyboard-repeat
# GNOME takes the gap *between* repeats in milliseconds rather than a rate,
# so the shared rate is inverted here (Settings > Keyboard).
gset org.gnome.desktop.peripherals.keyboard delay "$KEY_REPEAT_DELAY_MS"
gset org.gnome.desktop.peripherals.keyboard repeat-interval "$(( 1000 / KEY_REPEAT_RATE ))"

# intent: caps-as-escape
# gnome-tweaks > Keyboard & Mouse > Additional Layout Options > Caps Lock
# Behavior.
gset org.gnome.desktop.input-sources xkb-options "['caps:escape']"

# intent: alt-cvr-as-ctrl-cvr
# Evdev-level, via keyd; see install_alt_cvr_remap in desktop-common.sh.
install_alt_cvr_remap

# intent: no-screen-lock
# Settings > Privacy & Security > Screen Lock.
gset org.gnome.desktop.screensaver lock-enabled false
gset org.gnome.desktop.screensaver idle-activation-enabled false

# intent: no-idle-display
# Never dim or blank the display when idle, on AC or battery (Settings >
# Power).
gset org.gnome.desktop.session idle-delay 0
gset org.gnome.settings-daemon.plugins.power idle-dim false
gset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing
gset org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type nothing

# intent: no-automount
# Settings > Removable Media.
gset org.gnome.desktop.media-handling automount false
gset org.gnome.desktop.media-handling automount-open false

# intent: editable-path-bar
# GTK file open/save dialogs: an editable path bar instead of breadcrumbs,
# matching Dolphin's setting.
gset org.gtk.Settings.FileChooser location-mode filename-entry
gset org.gtk.gtk4.Settings.FileChooser location-mode filename-entry

# intent: dark-theme
# GNOME's equivalent of Breeze Dark (Settings > Appearance).
gset org.gnome.desktop.interface color-scheme prefer-dark
