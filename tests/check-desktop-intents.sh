#!/bin/bash
set -euo pipefail

# Checks that every desktop set accounts for every intent declared in
# config/desktop-common.sh.
#
# The gnome, kde and xfce sets apply the same decisions through three
# unrelated backends, so nothing stops one of them quietly falling behind the
# others. This is what stops it: add an intent to DESKTOP_INTENTS and this
# fails until all three sets mark where they handle it with a
#
#     # intent: <id>
#
# comment. It also fails on an intent id that isn't declared, which catches
# typos in those markers.
#
# Run by the lint job in .github/workflows/pr-test.yml, and by hand any time:
#     bash tests/check-desktop-intents.sh

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=config/desktop-common.sh
source "$REPO/config/desktop-common.sh"

DESKTOP_SETS=(gnome kde xfce)

# Intent ids, in declared order.
intent_ids=()
for entry in "${DESKTOP_INTENTS[@]}"; do
    intent_ids+=("${entry%%:*}")
done

# Every "# intent: <id>" marker found in a set's apply.sh, one per line.
markers_in() {
    grep -hoE '^# intent: [a-z0-9-]+' "$1" | sed 's/^# intent: //' || true
}

failures=()

# --- Coverage: every set implements every declared intent ------------------

printf 'Desktop intent coverage (config/desktop-common.sh):\n\n'
printf '  %-20s' 'intent'
printf '%-9s' "${DESKTOP_SETS[@]}"
printf '\n'

for id in "${intent_ids[@]}"; do
    printf '  %-20s' "$id"
    for set in "${DESKTOP_SETS[@]}"; do
        apply="$REPO/config/sets/$set/apply.sh"
        if [ ! -f "$apply" ]; then
            printf '%-9s' 'NO SET'
            failures+=("config/sets/$set/apply.sh does not exist")
        elif markers_in "$apply" | grep -qxF "$id"; then
            printf '%-9s' 'yes'
        else
            printf '%-9s' 'MISSING'
            failures+=("$set does not handle intent '$id' (add a '# intent: $id' marker to config/sets/$set/apply.sh, or drop the intent)")
        fi
    done
    printf '\n'
done
printf '\n'

# --- The other direction: no set claims an intent that isn't declared ------

for set in "${DESKTOP_SETS[@]}"; do
    apply="$REPO/config/sets/$set/apply.sh"
    [ -f "$apply" ] || continue
    while IFS= read -r marker; do
        [ -z "$marker" ] && continue
        printf '%s\n' "${intent_ids[@]}" | grep -qxF "$marker" && continue
        failures+=("$set marks intent '$marker', which isn't declared in config/desktop-common.sh (typo?)")
    done < <(markers_in "$apply")
done

# --- Verdict ---------------------------------------------------------------

if [ "${#failures[@]}" -gt 0 ]; then
    echo "Desktop intents are out of sync:" >&2
    for failure in "${failures[@]}"; do
        echo "  - $failure" >&2
    done
    exit 1
fi

echo "All ${#intent_ids[@]} intents covered by all ${#DESKTOP_SETS[@]} desktop sets."
