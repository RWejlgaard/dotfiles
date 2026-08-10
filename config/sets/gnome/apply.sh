#!/bin/bash
set -euo pipefail

# GNOME settings that diverge from stock defaults on this machine, mirroring
# config/sets/kde/apply.sh's choices for the GNOME desktop.
# Each section below is independent and safe to re-run.

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

# Keyboard repeat rate: 50 repeats/sec (20ms interval) with a 250ms initial
# delay (Settings > Keyboard).
gset org.gnome.desktop.peripherals.keyboard delay 250
gset org.gnome.desktop.peripherals.keyboard repeat-interval 20

# Remap Caps Lock to Escape (gnome-tweaks > Keyboard & Mouse > Additional
# Layout Options > Caps Lock Behavior).
gset org.gnome.desktop.input-sources xkb-options "['caps:escape']"

# Disable screen locking entirely (Settings > Privacy & Security > Screen
# Lock).
gset org.gnome.desktop.screensaver lock-enabled false
gset org.gnome.desktop.screensaver idle-activation-enabled false

# Never dim or blank the display when idle, on AC or battery (Settings >
# Power).
gset org.gnome.desktop.session idle-delay 0
gset org.gnome.settings-daemon.plugins.power idle-dim false
gset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing
gset org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type nothing

# Disable automounting of removable devices (Settings > Removable Media).
gset org.gnome.desktop.media-handling automount false
gset org.gnome.desktop.media-handling automount-open false

# GTK file open/save dialogs: use an editable path bar instead of
# breadcrumbs, matching Dolphin's setting.
gset org.gtk.Settings.FileChooser location-mode filename-entry
gset org.gtk.gtk4.Settings.FileChooser location-mode filename-entry

# Prefer a dark color scheme, GNOME's equivalent of Breeze Dark (Settings >
# Appearance).
gset org.gnome.desktop.interface color-scheme prefer-dark
