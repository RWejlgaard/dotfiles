#!/usr/bin/env fish

if not test -e ~/.tmux/plugins/tpm
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "tpm already installed"
end

# install tmux plugins

env TMUX_PLUGIN_MANAGER_PATH=~/.tmux/plugins ~/.tmux/plugins/tpm/bin/install_plugins