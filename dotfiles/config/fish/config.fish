export fish_greeting=""
export EDITOR=emacs

alias top=htop
alias get="brew install"
alias search="brew search"
alias vim=emacs
alias ls="ls -1GAF"
alias cat="bat"
alias ping="prettyping --nolegend"

alias k="kubectl"
alias kc="kubectl config use-context"
alias kp="kubectl get pods -A"
alias jupiter_auth="aws-azure-login --profile jupiter-auth --mode=gui"

export PATH="$PATH:/Users/Rasmus.Wejlgaard/Library/Python/3.7/bin"
export PATH="$PATH:/Users/Rasmus.Wejlgaard/homebrew/bin"
export PATH="$PATH:/Users/Rasmus.Wejlgaard/bin"
export HOMEBREW_CASK_OPTS="--appdir=/Users/Rasmus.Wejlgaard/apps"
export HOMEBREW_TEMP="/Users/Rasmus.Wejlgaard/brewtemp"

set -g theme_display_k8s_context yes

#test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish ; or true

#function iterm2_print_user_vars
#    iterm2_set_user_var kubeContext (kubectl config current-context)
#end

function update-ca-certificates
    security find-certificate -a -p /Library/Keychains/System.keychain > /Users/Rasmus.Wejlgaard/.ca-bundle.crt
    security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain >> /Users/Rasmus.Wejlgaard/.ca-bundle.crt
end

update-ca-certificates

export REQUESTS_CA_BUNDLE=/Users/Rasmus.Wejlgaard/.ca-bundle.crt
export NODE_EXTRA_CA_CERTS=/Users/Rasmus.Wejlgaard/.ca-bundle.crt
