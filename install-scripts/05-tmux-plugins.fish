#!/usr/bin/env fish

# install tmux plugin manager if not installed
if not test -e ~/.tmux/plugins/tpm
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
end

set -l tpm_path "$HOME/.tmux/plugins"

# tpm reads TMUX_PLUGIN_MANAGER_PATH out of tmux's global environment. A server
# it starts itself inherits ours, but a server that's already running won't - so
# set it there too. (`tmux start-server` is no help: an empty server exits
# immediately, since exit-empty is on by default.)
if tmux has-session 2>/dev/null
    tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$tpm_path"
end

# install/update tmux plugins
env TMUX_PLUGIN_MANAGER_PATH="$tpm_path" $tpm_path/tpm/bin/install_plugins