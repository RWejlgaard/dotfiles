set -g fish_greeting "" # Silence welcome message
set -gx EDITOR nvim

if status is-interactive
    and not set -q TMUX
    and not set -q SSH_CONNECTION
    and command -q tmux
    exec tmux new -As stuff
end
