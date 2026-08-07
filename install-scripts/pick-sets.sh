#!/bin/bash
set -euo pipefail

# `make picky`: an interactive dialog checklist for choosing which config
# sets (config/sets/<name>/) get deployed to this machine. The selection is
# remembered in $SETS_STATE_FILE so future `make refresh` / `make
# full-install` runs keep using it without asking again — re-run `make
# picky` any time to change your mind.
#
# On confirm, the Makefile's `picky` target runs the full install right
# after this script exits successfully. Exiting non-zero (e.g. on cancel)
# stops `make` before that happens.
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=install-scripts/lib/sets.sh
source "$REPO/install-scripts/lib/sets.sh"

ensure_dialog() {
    command -v dialog >/dev/null 2>&1 && return

    echo "Installing 'dialog' (needed for the config picker)..."
    if [ "$(uname)" == "Darwin" ]; then
        brew install dialog
    elif [ -f /etc/arch-release ]; then
        sudo pacman -S --noconfirm dialog
    elif [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y dialog
    elif [ -f /etc/alpine-release ]; then
        sudo apk add dialog
    elif [ "$(uname)" == "FreeBSD" ]; then
        sudo pkg install -y dialog
    elif [ -f /etc/redhat-release ]; then
        sudo dnf install -y dialog
    elif [ -f /etc/gentoo-release ]; then
        sudo emerge dialog
    else
        echo "Don't know how to install 'dialog' on this system; please install it manually and re-run 'make picky'." >&2
        exit 1
    fi
}

ensure_dialog

mapfile -t available < <(list_pickable_sets)
if [ "${#available[@]}" -eq 0 ]; then
    echo "No config sets found under config/sets/ that apply to this OS." >&2
    exit 1
fi

mapfile -t currently_enabled < <(enabled_sets)

is_enabled() {
    local set="$1"
    for enabled in "${currently_enabled[@]}"; do
        [ "$set" == "$enabled" ] && return 0
    done
    return 1
}

checklist_args=()
for set in "${available[@]}"; do
    status=off
    is_enabled "$set" && status=on
    checklist_args+=("$set" "$(set_description "$set")" "$status")
done

# Classic dialog idiom: swap stdout/stderr so the UI still draws on the real
# terminal (fd 3) while we capture the selected tags (written to stderr).
exec 3>&1
set +e
selection="$(dialog --backtitle "dotfiles" \
    --title "Pick your config sets" \
    --separate-output \
    --checklist "Space to toggle, Enter to confirm, Esc to cancel:" \
    20 70 "${#available[@]}" \
    "${checklist_args[@]}" \
    2>&1 1>&3)"
status=$?
set -e
exec 3>&-
clear

if [ "$status" -ne 0 ]; then
    echo "Cancelled, install not started."
    exit 1
fi

mkdir -p "$(dirname "$SETS_STATE_FILE")"
printf '%s\n' "$selection" | sed '/^$/d' > "$SETS_STATE_FILE"

if [ -s "$SETS_STATE_FILE" ]; then
    echo "Enabled sets: $(paste -sd, "$SETS_STATE_FILE")"
else
    echo "Enabled sets: (none)"
fi
