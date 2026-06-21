set -g fish_greeting "" # Silence welcome message
set -gx EDITOR nvim

if status is-interactive
    and not set -q TMUX
    and command -q tmux
    exec tmux new -As stuff
end
