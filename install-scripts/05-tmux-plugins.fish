#!/usr/bin/env fish

# install tmux plugin manager if not installed
if not test -e ~/.tmux/plugins/tpm
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
end

# install/update tmux plugins
env TMUX_PLUGIN_MANAGER_PATH=~/.tmux/plugins ~/.tmux/plugins/tpm/bin/install_plugins