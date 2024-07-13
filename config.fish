export fish_greeting="" # Silence welcome message

export EDITOR=nvim

if [ $TERM = "linux" ] # Asahi Linux TTY fixes
    setfont /usr/share/consolefonts/Lat2-Terminus32x16.psf.gz   # Make font bigger, it's unreadable by default
    export TERM=xterm-256color                                  # Pretty colors in TTY
    sudo dumpkeys | sed s/Caps_Lock/Escape/ | sudo loadkeys     # Rebind Caps Lock to escape
end

# aliases
if [ uname = "Darwin" ]
    alias get="brew install"
    alias search="brew search"
else if [ -f /etc/arch-release ]
    alias get="sudo pacman -S"
    alias search="pacman -Ss"
else if [ -f /etc/lsb-release ]
    alias get="sudo apt install"
    alias search="apt search"
else if [ -f /etc/alpine-release ]
    alias get="apk add"
    alias search="apk search"
end

alias vim=nvim
alias cat=bat
alias ping="prettyping --nolegend"

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

# misc paths to add disabled by default since they vary by OS
set -g fish_user_paths "/usr/local/opt/node@16/bin:$PATH" $fish_user_paths
