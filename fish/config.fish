#if not functions -q fundle; eval (curl -sfL https://git.io/fundle-install); end
export fish_greeting=""

export EDITOR=nvim

alias pez="ssh -X pez@localhost -t /usr/local/bin/fish"
alias get="brew install"
alias search="brew search"
alias vim=nvim
alias cat=bat
alias ping="prettyping --nolegend"

#alias type=cat
alias edit=nvim
alias dir=ls

alias k="kubectl"
alias kp="kubectl get pods -A"
alias gswitch="gcloud config configurations activate"
alias kc="kubectx"

function cheat --description "help <field> <topic>"
	set args (echo $argv[2..-1] | tr ' ' '+')
	curl "cht.sh/$argv[1]/$args"
end

function gitissue
  git reset --hard
  git checkout master
  git pull origin master
  git branch $argv[1]
  git checkout $argv[1]
end

set -g fish_user_paths "/Users/rasmus/airstrike" $fish_user_paths
set -g fish_user_paths "/Users/rasmus/Library/Python/3.9/bin" $fish_user_paths
set -g fish_user_paths "/nix/store/hw5v03wnc0k1pwgiyhblwlxb1fx5zyx8-nix-2.6.0/bin" $fish_user_paths

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/rasmus/google-cloud-sdk/path.fish.inc' ]; . '/Users/rasmus/google-cloud-sdk/path.fish.inc'; end
set -g fish_user_paths "/usr/local/opt/openjdk/bin" $fish_user_paths
#function iterm2_print_user_vars
#		iterm2_set_user_var kubecontext (kubectl config current-context)
#end
#source ~/.iterm2_shell_integration.fish
