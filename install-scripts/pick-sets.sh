#!/bin/bash
set -euo pipefail

# Chooses which config sets (config/sets/<name>/) get deployed to this
# machine, and remembers the choice in $SETS_STATE_FILE so future `make
# refresh` / `make full-install` runs keep using it without asking again.
#
# With no arguments (a bare `make`, or `make picky`) it shows an interactive
# dialog checklist. With set names as arguments it enables exactly those,
# non-interactively — that's how `make basic` skips the dialog.
#
# Either way the Makefile runs the full install right after this script
# exits successfully. Exiting non-zero (e.g. on cancel) stops `make` before
# that happens.
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=install-scripts/lib/sets.sh
source "$REPO/install-scripts/lib/sets.sh"

# Persist the given set names as this machine's selection.
save_sets() {
    mkdir -p "$(dirname "$SETS_STATE_FILE")"
    printf '%s\n' "$@" | sed '/^$/d' > "$SETS_STATE_FILE"

    if [ -s "$SETS_STATE_FILE" ]; then
        echo "Enabled sets: $(paste -sd, "$SETS_STATE_FILE")"
    else
        echo "Enabled sets: (none)"
    fi
}

# Non-interactive path: enable exactly the named sets and skip the dialog
# (and skip installing `dialog` in the first place).
if [ "$#" -gt 0 ]; then
    for set in "$@"; do
        if [ ! -d "$SETS_DIR/$set" ]; then
            echo "No config set named '$set' under config/sets/." >&2
            echo "Available: $(list_available_sets | paste -sd, -)" >&2
            exit 1
        fi
    done
    save_sets "$@"
    exit 0
fi

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

# Collected with read loops rather than `mapfile -t`: macOS still ships bash
# 3.2, which predates that builtin.
available=()
while IFS= read -r line; do
    available+=("$line")
done < <(list_pickable_sets)

if [ "${#available[@]}" -eq 0 ]; then
    echo "No config sets found under config/sets/ that apply to this OS." >&2
    exit 1
fi

currently_enabled=()
while IFS= read -r line; do
    currently_enabled+=("$line")
done < <(enabled_sets)

is_enabled() {
    local set="$1" enabled
    # Expanding an empty array trips `set -u` on bash 3.2, so check first —
    # deselecting every set is a legitimate state.
    if [ "${#currently_enabled[@]}" -gt 0 ]; then
        for enabled in "${currently_enabled[@]}"; do
            [ "$set" == "$enabled" ] && return 0
        done
    fi
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

save_sets "$selection"
