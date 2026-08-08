#!/bin/bash
set -euo pipefail

# KDE Plasma settings that diverge from stock defaults on this machine.
# Each section below is independent and safe to re-run.

kwriteconfig=""
for candidate in kwriteconfig6 kwriteconfig5; do
    if command -v "$candidate" >/dev/null 2>&1; then
        kwriteconfig="$candidate"
        break
    fi
done

if [ -z "$kwriteconfig" ]; then
    echo "Warning: kwriteconfig5/6 not found (not a KDE Plasma system?); skipping KDE settings." >&2
    exit 0
fi

# Keyboard repeat rate: 50 repeats/sec with a 250ms initial delay
# (System Settings > Keyboard > Advanced), via kcminputrc.
"$kwriteconfig" --file kcminputrc --group Keyboard --key RepeatDelay 250
"$kwriteconfig" --file kcminputrc --group Keyboard --key RepeatRate 50

# Apply immediately in the current X11 session; a fresh Plasma login also
# re-applies it from kcminputrc either way.
if [ -n "${DISPLAY:-}" ] && command -v xset >/dev/null 2>&1; then
    xset r rate 250 50 || true
fi

# Remap Caps Lock to Escape (System Settings > Keyboard > Advanced > Caps
# Lock behavior).
"$kwriteconfig" --file kxkbrc --group Layout --key Options "caps:escape"

# Disable screen locking entirely (System Settings > Screen Locking).
"$kwriteconfig" --file kscreenlockerrc --group Daemon --key Autolock false
"$kwriteconfig" --file kscreenlockerrc --group Daemon --key Timeout 0

# Never dim or turn off the display when idle, on AC or battery
# (System Settings > Power Management > Energy Saving).
for profile in AC Battery; do
    "$kwriteconfig" --file powerdevilrc --group "$profile" --group Display --key DimDisplayWhenIdle false
    "$kwriteconfig" --file powerdevilrc --group "$profile" --group Display --key TurnOffDisplayWhenIdle false
done

# Disable automounting of removable devices (System Settings > Removable
# Storage).
"$kwriteconfig" --file kded5rc --group Module-device_automounter --key autoload false

# Dolphin: hide the menu bar, and use an editable path bar instead of
# breadcrumbs in file open/save dialogs.
"$kwriteconfig" --file dolphinrc --group MainWindow --key MenuBar Disabled
"$kwriteconfig" --file kdeglobals --group "KFileDialog Settings" --key "Breadcrumb Navigation" false

# Use the Breeze Dark global theme (System Settings > Appearance > Global
# Theme).
if command -v plasma-apply-lookandfeel >/dev/null 2>&1; then
    plasma-apply-lookandfeel -a org.kde.breezedark.desktop || true
else
    "$kwriteconfig" --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop
fi
