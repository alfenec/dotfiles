# =========================================
# 0. Powerlevel10k instant prompt
# =========================================
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =========================================
# 1. Chargement de l'environnement (CRUCIAL)
# =========================================
# Nix profile
[ -e /etc/profile.d/nix.sh ] && source /etc/profile.d/nix.sh

# Devbox global : on le charge AVANT le reste pour avoir accès aux binaires
if [[ -z "$STARTUP_DONE" ]]; then
  if command -v devbox >/dev/null 2>&1 && [[ -f ~/dotfiles/devbox.json ]]; then
    pushd ~/dotfiles >/dev/null
    eval "$(devbox shellenv)"
    popd >/dev/null
  fi
fi

# =========================================
# 2. Options Zsh & Plugins
# =========================================
setopt SHARE_HISTORY
HISTSIZE=10000
SAVEHIST=10000

# Initialisation de Zoxide (Maintenant il le trouvera !)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# direnv
export DIRENV_LOG_FORMAT=""
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# =========================================
# 3. Thème & Plugins visuels
# =========================================
P10K_DIR="$HOME/dotfiles/powerlevel10k"
[[ -f "$P10K_DIR/powerlevel10k.zsh-theme" ]] && source "$P10K_DIR/powerlevel10k.zsh-theme"
[[ -f "$HOME/dotfiles/.p10k.zsh" ]] && source "$HOME/dotfiles/.p10k.zsh"

# Suggestions & Highlighting
[ -f "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# =========================================
# 4. Alias (ls, k8s, etc.)
# =========================================
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --group-directories-first'
alias la='eza -a --icons --group-directories-first'
alias k='kubecolor'
alias kubectl='kubecolor'
alias kn='k9s'
alias y='yazi'
alias lg='lazygit'
alias v='nvim'
alias ff='fastfetch'
alias t2='tree -L 2'
alias t3='tree -L 3'
alias t='task'
alias ns='kubens'
alias ctx='kubectx'
alias mc='mcli'

# =========================================
# 5. Startup Interactive (Clear & Welcome)
# =========================================
if [[ -o interactive ]] && [[ -z "$STARTUP_DONE" ]]; then
  export STARTUP_DONE=1
  export KUBECONFIG="$HOME/.kube/config:/etc/rancher/k3s/k3s.yaml"
  
  clear
  command -v neofetch >/dev/null 2>&1 && neofetch || neofetch
  echo "🚀 Roof Kubernetes prêt !"
fi

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
