# =========================================
# 0. Powerlevel10k instant prompt
# =========================================
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =========================================
# 1. Options Zsh
# =========================================
setopt SHARE_HISTORY
HISTSIZE=10000
SAVEHIST=10000

# =========================================
# 2. Nix / direnv
# =========================================
# Nix profile
[ -e /etc/profile.d/nix.sh ] && source /etc/profile.d/nix.sh

# direnv
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# =========================================
# 3. Powerlevel10k theme
# =========================================
P10K_DIR="$HOME/dotfiles/powerlevel10k"
[[ -f "$P10K_DIR/powerlevel10k.zsh-theme" ]] && source "$P10K_DIR/powerlevel10k.zsh-theme"
[[ -f "$HOME/dotfiles/.p10k.zsh" ]] && source "$HOME/dotfiles/.p10k.zsh"

# =========================================
# 4. Plugins Zsh (sans Oh My Zsh)
# =========================================
# Suppression de l'ancien 'z' et remplacement par zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# autosuggestions
[ -f "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# syntax highlighting (doit être en dernier)
[ -f "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# =========================================
# 5. Alias confort
# =========================================
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --group-directories-first'
alias la='eza -a --icons --group-directories-first'

# =========================================
# 6. Alias Kubernetes & Dev/Ops
# =========================================
alias k='kubecolor'
alias kubectl='kubecolor'
alias mc='mcli'
alias kn='k9s'
alias ctx='kubectx'
alias ns='kubens'
alias t='task'
alias t2='tree -L 2'
alias t3='tree -L 3'
alias ff='fastfetch'
alias y='yazi'       # Ton nouveau navigateur
alias lg='lazygit'   # Ton interface Git
alias v='nvim'       # Plus rapide à taper

# =========================================
# 7. Devbox + Neofetch + message 🚀 (une seule fois)
# =========================================
if [[ -o interactive ]] && [[ -z "$STARTUP_DONE" ]]; then
  export STARTUP_DONE=1

  # Devbox global
  if command -v devbox >/dev/null 2>&1 && [[ -f ~/dotfiles/devbox.json ]]; then
    pushd ~/dotfiles >/dev/null
    eval "$(devbox shellenv)"
    popd >/dev/null
  fi

  # Affichage système
  command -v neofetch >/dev/null 2>&1 && neofetch

  # Kubernetes
  export KUBECONFIG="$HOME/.kube/config:/etc/rancher/k3s/k3s.yaml"

  # Message de bienvenue
  echo "🚀 Roof Kubernetes prêt !"
fi

# =========================================
# 8. FZF
# =========================================
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# =========================================
# 9. Dossier de départ
# =========================================
cd ~/gitops

