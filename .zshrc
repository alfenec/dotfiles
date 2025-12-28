###############################################
# 1. Oh My Zsh & Plugins
###############################################
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git 
  z 
  sudo 
  extract 
  zsh-autosuggestions 
  zsh-syntax-highlighting 
  you-should-use 
  kubectl 
  helm 
  argocd
)

source $ZSH/oh-my-zsh.sh

###############################################
# 2. Thème Powerlevel10k
###############################################
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme

###############################################
# 3. Intégration Devbox & Direnv
###############################################
if command -v devbox >/dev/null; then
  eval "$(devbox generate direnv --print-config)"
  eval "$(direnv hook zsh)"
fi

###############################################
# 4. Alias Confort (eza, bat, btop)
###############################################
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --group-directories-first'
alias la='eza -a --icons --group-directories-first'
alias cat='bat'
alias top='btop' # Remplace le vieux top par le btop moderne

###############################################
# 5. Alias Kubernetes & Ops
###############################################
alias k='kubecolor'
alias kubectl='kubecolor'
alias kn='k9s'
alias ctx='kubectx'
alias ns='kubens'
alias mc='mcli'
alias t='task'

# Tree rapide
alias t2='tree -L 2'
alias t3='tree -L 3'

###############################################
# 6. FZF & Historique
###############################################
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
