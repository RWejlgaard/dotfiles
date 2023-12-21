export fish_greeting=""

export EDITOR=nvim

if [ $TERM = "linux" ] # Asahi Linux TTY fixes
    setfont /usr/share/consolefonts/Lat2-Terminus32x16.psf.gz   # Make font bigger, it's unreadable by default
    export TERM=xterm-256color                                  # Pretty colors in TTY
    sudo dumpkeys | sed s/Caps_Lock/Escape/ | sudo loadkeys     # Rebind Caps Lock to escape
end

# aliases
alias get="sudo dnf install -y"
alias search="dnf search"
alias vim=nvim
alias cat=bat
alias ping="prettyping --nolegend"
alias edit=nvim # DOS-style alias for nvim
alias dir=ls    # DOS-style alias for ls

alias k="kubectl"
alias kp="kubectl get pods -A"
alias gswitch="gcloud config configurations activate"
alias kc="kubectx"

# lookup various commands/syntax in a pinch
function cheat --description "help <field> <topic>"
	set args (echo $argv[2..-1] | tr ' ' '+')
	curl "cht.sh/$argv[1]/$args"
end

# update master and create a branch with value: $1
function gitissue
  git reset --hard
  git checkout master
  git pull origin master
  git branch $argv[1]
  git checkout $argv[1]
end

#export XDG_CONFIG_HOME="$HOME/.config"

# misc paths to add disabled by default since they vary by OS
set -g fish_user_paths "/usr/local/opt/node@16/bin:$PATH" $fish_user_paths

# Regular syntax highlighting colors
set -g fish_color_normal normal
set -g fish_color_command 005fd7 purple
set -g fish_color_param 00afff cyan
set -g fish_color_redirection normal
set -g fish_color_comment red
set -g fish_color_error red --bold
set -g fish_color_escape cyan
set -g fish_color_operator cyan
set -g fish_color_quote brown
set -g fish_color_autosuggestion 555 yellow
set -g fish_color_valid_path --underline
set -g fish_color_cwd green
set -g fish_color_cwd_root red
set -g fish_color_history_current cyan

# Background color for matching quotes and parenthesis
set -g fish_color_match cyan

# Background color for search matches
set -g fish_color_search_match --background=purple

# Pager colors
set -g fish_pager_color_prefix cyan
set -g fish_pager_color_completion normal
set -g fish_pager_color_description 555 yellow
set -g fish_pager_color_progress cyan

# I ❤️ gruvbox
set -g theme_color_scheme gruvbox
