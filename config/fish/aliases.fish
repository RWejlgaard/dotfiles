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
else if [ -f /etc/gentoo-release ]
    alias get="sudo emerge"
    alias search="emerge --search"
end

alias vim=nvim
alias cat="bat -Pp"
alias lg=lazygit
alias ls=eza

alias k="kubectl"
alias kp="kubectl get pods -A"
alias kc="kubectx"

# Gentoo
alias gentoo-check-update="sudo emerge --sync; and sudo emerge -avuDNp @world | genlop -p"
alias gentoo-upgrade="sudo emerge -avuDN @world"

function gentoo-package-use
    sudo vim /etc/portage/package.use/$argv
end

# Volume control (pipewire)
function vol
    wpctl set-volume @DEFAULT_SINK@ $argv% 2>&1 > /dev/null
end
