#!/bin/bash
set -euo pipefail

# Deploy tracked config files into place so edits to the live config flow
# straight back to the repo (no more "tweaked it and lost it on refresh").
# Which files get deployed depends on which config "sets" are enabled for
# this machine — see config/sets/ and `make picky`.
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=install-scripts/lib/sets.sh
source "$REPO/install-scripts/lib/sets.sh"

# Symlink SRC -> DEST, backing up any pre-existing real file to DEST.bak first.
link() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Backing up existing $dest -> $dest.bak"
        mv "$dest" "$dest.bak"
    fi
    ln -sf "$src" "$dest"
}

# Copy SRC -> DEST only if DEST doesn't already exist yet, so per-machine
# customizations (e.g. envvars.fish, status.conf) survive re-runs.
copy_if_missing() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [ ! -f "$dest" ]; then
        cp "$src" "$dest"
    fi
}

# Deploy one config set by walking its manifest (see config/sets/*/manifest
# for the format).
deploy_set() {
    local set="$1"
    local set_dir="$SETS_DIR/$set"
    local manifest="$set_dir/manifest"

    if [ ! -f "$manifest" ]; then
        echo "Warning: set '$set' has no manifest, skipping." >&2
        return
    fi

    echo "Deploying config set: $set"
    while read -r action src dest; do
        [ -z "$action" ] && continue
        [[ "$action" == \#* ]] && continue

        dest="${dest/#\~/$HOME}"

        case "$action" in
            link)
                link "$set_dir/$src" "$dest"
                ;;
            copy)
                copy_if_missing "$set_dir/$src" "$dest"
                ;;
            link-glob)
                for f in "$set_dir"/$src; do
                    [ -e "$f" ] || continue
                    link "$f" "$dest/$(basename "$f")"
                done
                ;;
            run)
                bash "$set_dir/$src" || echo "Warning: $src (set '$set') exited non-zero." >&2
                ;;
            *)
                echo "Warning: unknown action '$action' in $manifest, skipping." >&2
                ;;
        esac
    done < "$manifest"
}

while IFS= read -r set; do
    deploy_set "$set"
done < <(enabled_sets)
