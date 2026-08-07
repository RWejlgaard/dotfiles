#!/bin/bash
set -euo pipefail

# Sets the KDE Plasma keyboard repeat rate to 50 repeats/sec with a 250ms
# initial delay (System Settings > Keyboard > Advanced), via kcminputrc.

kwriteconfig=""
for candidate in kwriteconfig6 kwriteconfig5; do
    if command -v "$candidate" >/dev/null 2>&1; then
        kwriteconfig="$candidate"
        break
    fi
done

if [ -z "$kwriteconfig" ]; then
    echo "Warning: kwriteconfig5/6 not found (not a KDE Plasma system?); skipping keyboard repeat settings." >&2
    exit 0
fi

"$kwriteconfig" --file kcminputrc --group Keyboard --key RepeatDelay 250
"$kwriteconfig" --file kcminputrc --group Keyboard --key RepeatRate 50

# Apply immediately in the current X11 session; a fresh Plasma login also
# re-applies it from kcminputrc either way.
if [ -n "${DISPLAY:-}" ] && command -v xset >/dev/null 2>&1; then
    xset r rate 250 50 || true
fi
