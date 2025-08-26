# aliases

# Package manager aliases
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
else if [ uname = "FreeBSD" ]
    alias get="sudo pkg install -y"
    alias search="pkg search"
end

alias vim=nvim
alias cat="bat -Pp"

alias k="kubectl"
alias kp="kubectl get pods -A"
alias gswitch="gcloud config configurations activate"
alias kc="kubectx"
