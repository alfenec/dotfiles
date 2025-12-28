###############################################
# 0. Début : options Zsh
###############################################
setopt SHARE_HISTORY
HISTSIZE=10000
SAVEHIST=10000

###############################################
# 1. Activation Nix & Devbox
###############################################
# Source Nix (si installé)
[ -e /etc/profile.d/nix.sh ] && source /etc/profile.d/nix.sh

# Source Devbox pour la session courante
if command -v devbox >/dev/null; then
    eval "$(devbox shellenv)"
fi

# Activer direnv
if command -v direnv >/dev/null; then
    eval "$(direnv hook zsh)"
fi

###############################################
# 2. Oh My Zsh
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
# 3. Powerlevel10k
###############################################
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme

###############################################
# 4. Alias confort
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

# Tree rapide
alias t2='tree -L 2'
alias t3='tree -L 3'

###############################################
# 6. FZF
###############################################
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
