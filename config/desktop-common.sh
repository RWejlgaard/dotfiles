# shellcheck shell=bash
# Shared ground truth for the desktop sets — gnome, kde and xfce.
#
# Those three sets say the same things to three completely different
# backends (gsettings, kwriteconfig, xfconf-query), so there's little code
# worth sharing between them. What *is* worth sharing is the decision behind
# the code: which settings this repo has an opinion about, and what that
# opinion is. Without that written down once, adding a setting to one desktop
# and forgetting the other two is invisible.
#
# The one exception is install_alt_cv_remap below: it's evdev-level (via
# keyd), below X11/Wayland and every desktop's own config backend, so the
# shell to apply it is identical for all three and lives here once instead
# of being copy-pasted three times.
#
# So: every setting all three desktops are expected to cover gets an entry in
# DESKTOP_INTENTS below, and each apply.sh marks where it handles it with a
#
#     # intent: <id>
#
# comment. tests/check-desktop-intents.sh cross-references the two and fails
# if a desktop is missing one, or claims an id that doesn't exist here.
# Settings that only make sense on one desktop (Dolphin's menu bar, XFCE's
# panel layout) aren't intents and need no annotation.
#
# The macos set is deliberately out of scope: it isn't a desktop environment
# in this sense, its settings mostly have no Linux equivalent, and the few
# that overlap use units that don't convert cleanly.
#
# Sourced by config/sets/{gnome,kde,xfce}/apply.sh.

# Values every desktop should end up applying, in their canonical units.
# Each backend converts as needed — GNOME, for one, wants the repeat
# *interval* in milliseconds rather than a rate.
KEY_REPEAT_RATE=50       # repeats per second, once repeating starts
KEY_REPEAT_DELAY_MS=250  # milliseconds held before repeating starts

# "<id>:<what it means>", one per setting all three desktops should cover.
# shellcheck disable=SC2034  # read by tests/check-desktop-intents.sh, which sources this
DESKTOP_INTENTS=(
    "keyboard-repeat:Key repeat at ${KEY_REPEAT_RATE}/s after a ${KEY_REPEAT_DELAY_MS}ms delay"
    "caps-as-escape:Caps Lock acts as Escape"
    "no-screen-lock:Screen locking disabled entirely"
    "no-idle-display:Display never dims or blanks when idle, on AC or battery"
    "no-automount:Removable devices are not automounted"
    "editable-path-bar:File dialogs offer an editable path entry, not breadcrumbs"
    "dark-theme:A dark colour scheme"
    "alt-cvr-as-ctrl-cvr:Alt+C/V/R send Ctrl+C/V/R, system-wide"
)

# Installs keyd (if missing) and points it at a config that remaps Alt+C to
# Ctrl+C, Alt+V to Ctrl+V, and Alt+R to Ctrl+R, system-wide. This is below
# any window system, so it's the same on every desktop (and every
# Wayland/X11 session on it) — called by each desktop's apply.sh under its
# own "# intent: alt-cvr-as-ctrl-cvr" marker.
install_alt_cvr_remap() {
    if ! command -v keyd >/dev/null 2>&1; then
        if [ -f /etc/arch-release ]; then
            sudo pacman -S --noconfirm keyd
        elif [ -f /etc/debian_version ]; then
            export DEBIAN_FRONTEND=noninteractive
            sudo apt update && sudo apt install -y keyd
        elif [ -f /etc/alpine-release ]; then
            sudo apk add keyd
        elif [ -f /etc/redhat-release ]; then
            sudo dnf install -y keyd
        elif [ -f /etc/gentoo-release ]; then
            sudo emerge app-misc/keyd
        else
            echo "Warning: don't know how to install keyd on this system; install it manually." >&2
            return 1
        fi
    fi

    sudo mkdir -p /etc/keyd
    sudo tee /etc/keyd/dotfiles-alt-cvr.conf >/dev/null <<'EOF'
[ids]
*

[alt]
c = C-c
v = C-v
r = C-r
EOF

    sudo systemctl enable --now keyd >/dev/null 2>&1 || true
    sudo keyd reload || true
}
