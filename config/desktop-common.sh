# shellcheck shell=bash
# Shared ground truth for the desktop sets — gnome, kde and xfce.
#
# Those three sets say the same things to three completely different
# backends (gsettings, kwriteconfig, xfconf-query), so there's no code worth
# sharing between them. What *is* worth sharing is the decision behind the
# code: which settings this repo has an opinion about, and what that opinion
# is. Without that written down once, adding a setting to one desktop and
# forgetting the other two is invisible.
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
)
