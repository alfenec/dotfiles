###############################################
# 1. Activation de Nix
###############################################
# Charge Nix
if [ -e /etc/profile.d/nix.sh ]; then
  source /etc/profile.d/nix.sh
fi

# Active direnv si présent (DEVBOX via direnv uniquement)
if command -v direnv >/dev/null; then
  eval "$(direnv hook zsh)"
fi


###############################################
# 2. Oh My Zsh & Plugins
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
# 3. Thème Powerlevel10k
###############################################
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme


###############################################
# 4. Alias Confort
###############################################
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --group-directories-first'
alias la='eza -a --icons --group-directories-first'
alias cat='bat'
alias top='btop'


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

alias t2='tree -L 2'
alias t3='tree -L 3'


###############################################
# 6. FZF & Historique
###############################################
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
