#!/bin/bash
set -euo pipefail

# Installs the Gentoo kernel upgrade helper (scripts/gentoo-kernel-upgrade)
# into /usr/bin, mirroring config/sets/xfce/apply.sh's install_kitty.
#
# This used to live in install-scripts/07-last-touches.sh, where it ran on
# every Gentoo install and had to stop and ask which init system was in use
# — which blocked unattended installs. The helper works its own kernel
# naming out at runtime now, so this is a plain copy, and it's opt-in via
# `make picky` rather than automatic.

if [ ! -f /etc/gentoo-release ]; then
    echo "Warning: /etc/gentoo-release not found (not a Gentoo system?); skipping Gentoo settings." >&2
    exit 0
fi

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

# install(1) rather than cp so the mode is set explicitly, and so an
# already-running copy of the script isn't rewritten underneath itself.
sudo install -m 755 "$REPO/scripts/gentoo-kernel-upgrade" /usr/bin/gentoo-kernel-upgrade

echo "Installed /usr/bin/gentoo-kernel-upgrade"
