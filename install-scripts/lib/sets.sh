# shellcheck shell=bash
# Shared helpers for working with config "sets" (config/sets/<name>/).
# Sourced by pick-sets.sh and 02-move-files.sh — not meant to be run directly.

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SETS_DIR="$REPO/config/sets"
SETS_STATE_FILE="$HOME/.config/dotfiles/sets.conf"

# Print the names of all sets available in the repo, one per line.
list_available_sets() {
    for dir in "$SETS_DIR"/*/; do
        [ -d "$dir" ] || continue
        basename "$dir"
    done
}

# Whether SET applies to the OS this is running on. Sets without an "os"
# file (see config/sets/*/os) are OS-agnostic and always apply; sets with
# one only apply if it lists the current `uname -s` output.
set_applies_to_current_os() {
    local set="$1"
    local os_file="$SETS_DIR/$set/os"
    [ -f "$os_file" ] || return 0
    grep -qxF "$(uname -s)" "$os_file"
}

# Print the names of sets available in the repo AND applicable to this OS,
# one per line -- what `make picky` should offer to choose from.
list_pickable_sets() {
    while IFS= read -r set; do
        set_applies_to_current_os "$set" && echo "$set"
    done < <(list_available_sets)
}

# Print the names of the sets currently enabled for this machine, one per
# line. Falls back to just "basic" if `make picky` has never been run, so a
# plain `make full-install` / `make refresh` keeps today's behavior.
enabled_sets() {
    local sets=()
    if [ -f "$SETS_STATE_FILE" ]; then
        while IFS= read -r line; do
            [ -z "$line" ] && continue
            sets+=("$line")
        done < "$SETS_STATE_FILE"
    else
        sets=("basic")
    fi

    # Expanding an empty array trips `set -u` on bash 3.2 (which is what
    # macOS ships), and an empty sets.conf -- every set deselected -- is a
    # legitimate state.
    [ "${#sets[@]}" -eq 0 ] && return 0

    for set in "${sets[@]}"; do
        if [ ! -d "$SETS_DIR/$set" ]; then
            echo "Warning: enabled set '$set' no longer exists in the repo, skipping." >&2
        elif ! set_applies_to_current_os "$set"; then
            echo "Warning: enabled set '$set' doesn't apply to this OS ($(uname -s)), skipping." >&2
        else
            echo "$set"
        fi
    done
}

# A short human-readable blurb for a set, shown next to it in `make picky`.
# Falls back to a generic description if the set doesn't provide one.
set_description() {
    local set="$1"
    local desc_file="$SETS_DIR/$set/description"
    if [ -f "$desc_file" ]; then
        head -n1 "$desc_file"
    else
        echo "$set settings"
    fi
}
