#!/bin/bash
set -euo pipefail

# KDE Plasma settings that diverge from stock defaults on this machine.
# Each section below is independent and safe to re-run.
#
# The "# intent:" markers below tie each section to an entry in
# config/desktop-common.sh, which is the one place the kde/gnome/xfce sets
# agree on what they're all supposed to cover.

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
# shellcheck source=config/desktop-common.sh
source "$REPO/config/desktop-common.sh"

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

# intent: keyboard-repeat
# System Settings > Keyboard > Advanced, via kcminputrc.
"$kwriteconfig" --file kcminputrc --group Keyboard --key RepeatDelay "$KEY_REPEAT_DELAY_MS"
"$kwriteconfig" --file kcminputrc --group Keyboard --key RepeatRate "$KEY_REPEAT_RATE"

# Apply immediately in the current X11 session; a fresh Plasma login also
# re-applies it from kcminputrc either way.
if [ -n "${DISPLAY:-}" ] && command -v xset >/dev/null 2>&1; then
    xset r rate "$KEY_REPEAT_DELAY_MS" "$KEY_REPEAT_RATE" || true
fi

# intent: caps-as-escape
# System Settings > Keyboard > Advanced > Caps Lock behavior.
"$kwriteconfig" --file kxkbrc --group Layout --key Options "caps:escape"

# intent: no-screen-lock
# System Settings > Screen Locking.
"$kwriteconfig" --file kscreenlockerrc --group Daemon --key Autolock false
"$kwriteconfig" --file kscreenlockerrc --group Daemon --key Timeout 0

# intent: no-idle-display
# Never dim or turn off the display when idle, on AC or battery
# (System Settings > Power Management > Energy Saving).
for profile in AC Battery; do
    "$kwriteconfig" --file powerdevilrc --group "$profile" --group Display --key DimDisplayWhenIdle false
    "$kwriteconfig" --file powerdevilrc --group "$profile" --group Display --key TurnOffDisplayWhenIdle false
done

# intent: no-automount
# System Settings > Removable Storage.
"$kwriteconfig" --file kded5rc --group Module-device_automounter --key autoload false

# Dolphin: hide the menu bar. KDE-only, so not a shared intent.
"$kwriteconfig" --file dolphinrc --group MainWindow --key MenuBar Disabled

# intent: editable-path-bar
# An editable path bar instead of breadcrumbs in file open/save dialogs.
"$kwriteconfig" --file kdeglobals --group "KFileDialog Settings" --key "Breadcrumb Navigation" false

# intent: dark-theme
# The Breeze Dark global theme (System Settings > Appearance > Global Theme).
if command -v plasma-apply-lookandfeel >/dev/null 2>&1; then
    plasma-apply-lookandfeel -a org.kde.breezedark.desktop || true
else
    "$kwriteconfig" --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop
fi
