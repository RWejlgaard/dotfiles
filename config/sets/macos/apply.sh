#!/bin/bash
set -euo pipefail

# macOS settings that diverge from stock defaults on this machine.
# Each section below is independent and safe to re-run.
#
# Some of these only take effect in apps launched afterwards; the Dock,
# Finder and SystemUIServer are restarted at the end to pick up the rest.

if [ "$(uname)" != "Darwin" ] || ! command -v defaults >/dev/null 2>&1; then
    echo "Warning: not macOS (or 'defaults' unavailable); skipping macOS settings." >&2
    exit 0
fi

# --- Keyboard -------------------------------------------------------------

# Keyboard repeat rate as fast as possible and the initial repeat delay as
# short as possible — below the range the System Settings slider exposes.
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Turn off every "helpful" text substitution (System Settings > Keyboard >
# Input Sources > Edit). They fight with writing code and shell commands.
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticInlinePredictionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false

# Text replacements (System Settings > Keyboard > Text Replacements).
# Note this replaces the whole list, including macOS's stock "omw" entry —
# which is why it's repeated here.
#
# These use XML plist literals rather than `defaults`' old-style `{ k = v; }`
# syntax, which types every scalar as a string — macOS wants a real integer
# in `on` and a real boolean in the hotkey dicts below.
defaults write NSGlobalDomain NSUserDictionaryReplacementItems '<array>
  <dict><key>on</key><integer>1</integer><key>replace</key><string>omw</string><key>with</key><string>On my way!</string></dict>
  <dict><key>on</key><integer>1</integer><key>replace</key><string>/stern</string><key>with</key><string>ಠ_ಠ</string></dict>
  <dict><key>on</key><integer>1</integer><key>replace</key><string>/shrug</string><key>with</key><string>¯\_(ツ)_/¯</string></dict>
</array>'

# Free up Ctrl+Space / Ctrl+Opt+Space by disabling the "select previous /
# next input source" shortcuts (System Settings > Keyboard > Keyboard
# Shortcuts > Input Sources), and drop the Quick Note hotkey while we're
# here (Keyboard Shortcuts > Mission Control).
disable_hotkey() {
    local id="$1" p1="$2" p2="$3" p3="$4"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$id" \
        "<dict>
           <key>enabled</key><false/>
           <key>value</key><dict>
             <key>parameters</key><array>
               <integer>$p1</integer><integer>$p2</integer><integer>$p3</integer>
             </array>
             <key>type</key><string>standard</string>
           </dict>
         </dict>"
}
disable_hotkey 60 32 49 262144      # select the previous input source
disable_hotkey 61 32 49 786432      # select the next input source
disable_hotkey 164 65535 65535 0    # show Quick Note

# --- Appearance -----------------------------------------------------------

# Dark mode (System Settings > Appearance).
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark

# Trackpad tracking speed, faster than the 0.6875 default
# (System Settings > Trackpad > Point & Click).
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1

# Show seconds in the menu bar clock (System Settings > Control Centre >
# Menu Bar Only > Clock Options).
defaults write com.apple.menuextra.clock ShowSeconds -bool true

# --- Dock -----------------------------------------------------------------

# No "Recent Applications" section in the Dock (System Settings > Desktop &
# Dock).
defaults write com.apple.dock show-recents -bool false

# --- Window tiling --------------------------------------------------------

# Disable macOS's own drag-to-edge window tiling and its margins — window
# management is Rectangle's job (System Settings > Desktop & Dock > Windows).
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool false

# --- Finder ---------------------------------------------------------------

# List view by default, new windows open on ~, and keep the status bar.
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
defaults write com.apple.finder NewWindowTarget -string PfHm
defaults write com.apple.finder ShowStatusBar -bool true

# --- Screenshots ----------------------------------------------------------

# Screenshots go to the clipboard rather than the Desktop. `target` is the
# older key, `target-screenshot` the one Sonoma and later actually read.
defaults write com.apple.screencapture target -string clipboard
defaults write com.apple.screencapture target-screenshot -string clipboard

# --- Privacy --------------------------------------------------------------

# Opt out of Apple's personalised advertising (System Settings > Privacy &
# Security > Apple Advertising).
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false

# --- Apps -----------------------------------------------------------------

# Rectangle (window management) and Maccy (clipboard history), plus the
# shortcuts and options they're configured with here.
#
# Both apps write their whole preference domain back out when they quit, so
# a `defaults write` against a running app gets silently clobbered. Each one
# is therefore quit first, configured, and only relaunched if it was already
# running.

install_cask() {
    local cask="$1"
    if ! command -v brew >/dev/null 2>&1; then
        echo "Warning: Homebrew not found; skipping '$cask'." >&2
        return 1
    fi
    brew list --cask "$cask" >/dev/null 2>&1 || brew install --cask "$cask"
}

app_is_running() {
    pgrep -qx "$1" 2>/dev/null
}

quit_app() {
    app_is_running "$1" || return 0
    osascript -e "quit app \"$1\"" >/dev/null 2>&1 || killall "$1" >/dev/null 2>&1 || true
    # Give the app a moment to flush its preferences before we overwrite them.
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        app_is_running "$1" || break
        sleep 0.5
    done
}

# Rectangle shortcuts are stored as { keyCode, modifierFlags } dictionaries;
# XML plist literals keep both as real integers.
rectangle_shortcut() {
    defaults write com.knollsoft.Rectangle "$1" \
        "<dict>
           <key>keyCode</key><integer>$2</integer>
           <key>modifierFlags</key><integer>$3</integer>
         </dict>"
}

if install_cask rectangle; then
    rectangle_was_running=false
    if app_is_running Rectangle; then
        rectangle_was_running=true
    fi
    quit_app Rectangle

    # 1179648 = Command + Shift, 786432 = Control + Option.
    rectangle_shortcut leftHalf   123 1179648   # Cmd+Shift+Left
    rectangle_shortcut rightHalf  124 1179648   # Cmd+Shift+Right
    rectangle_shortcut maximize   126 1179648   # Cmd+Shift+Up
    rectangle_shortcut center     125 1179648   # Cmd+Shift+Down
    rectangle_shortcut toggleTodo  11  786432   # Ctrl+Opt+B
    rectangle_shortcut reflowTodo  45  786432   # Ctrl+Opt+N

    # Accept shortcuts macOS would otherwise reserve, keep the menu bar
    # clear, and don't nag about updates (the cask handles those).
    defaults write com.knollsoft.Rectangle allowAnyShortcut -bool true
    defaults write com.knollsoft.Rectangle hideMenubarIcon -bool true
    defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 0
    defaults write com.knollsoft.Rectangle windowSnapping -int 1
    defaults write com.knollsoft.Rectangle SUEnableAutomaticChecks -bool false

    if [ "$rectangle_was_running" = true ]; then
        open -a Rectangle || true
    else
        echo "Note: Rectangle needs Accessibility permission on first launch" >&2
        echo "      (System Settings > Privacy & Security > Accessibility)." >&2
    fi
fi

if install_cask maccy; then
    maccy_was_running=false
    if app_is_running Maccy; then
        maccy_was_running=true
    fi
    quit_app Maccy

    # Maccy stores shortcuts as JSON strings of Carbon key/modifier codes.
    # 768 = cmdKey + shiftKey, 2048 = optionKey.
    defaults write org.p0deje.Maccy KeyboardShortcuts_popup \
        -string '{"carbonKeyCode":9,"carbonModifiers":768}'    # Cmd+Shift+V
    defaults write org.p0deje.Maccy KeyboardShortcuts_pin \
        -string '{"carbonKeyCode":35,"carbonModifiers":2048}'  # Opt+P
    defaults write org.p0deje.Maccy KeyboardShortcuts_delete \
        -string '{"carbonKeyCode":51,"carbonModifiers":2048}'  # Opt+Delete

    # Open the history under the menu bar item rather than at the pointer.
    defaults write org.p0deje.Maccy popupPosition -string statusItem
    defaults write org.p0deje.Maccy windowSize -string '[450,800]'
    defaults write org.p0deje.Maccy SUEnableAutomaticChecks -bool false

    if [ "$maccy_was_running" = true ]; then
        open -a Maccy || true
    fi
fi

# --- Power ----------------------------------------------------------------

# Never blank the display when idle, on battery or mains — same choice as
# the kde set makes. Needs root, so it's skipped rather than prompting when
# passwordless sudo isn't available.
if command -v pmset >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    sudo -n pmset -b displaysleep 0
    sudo -n pmset -c displaysleep 0
else
    echo "Note: skipping 'pmset displaysleep 0' (needs sudo). Run manually:" >&2
    echo "  sudo pmset -b displaysleep 0 && sudo pmset -c displaysleep 0" >&2
fi

# --- Apply ----------------------------------------------------------------

# Restart the affected agents so the settings above show up now instead of
# at next login. Finder windows are reopened by Finder itself.
for app in Dock Finder SystemUIServer; do
    killall "$app" >/dev/null 2>&1 || true
done
