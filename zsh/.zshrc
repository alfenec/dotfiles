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
  if command -v devbox >/dev/null 2>&1; then
    # On pointe directement vers le bon dossier où se trouve ton devbox.json
    eval "$(devbox shellenv --config ~/dotfiles/devbox)"
  fi
fi

# =========================================
# 2. Options Zsh & Plugins
# =========================================
export HISTFILE="$HOME/.zsh_history"
setopt append_history     # Ajoute au fichier plutôt que de l'écraser
setopt hist_ignore_space   # Astuce : ne pas enregistrer les commandes commençant par un espace
setopt hist_reduce_blanks  # Supprime les espaces superflus dans l'historique
setopt hist_ignore_dups   # Ne pas enregistrer la même commande deux fois de suite
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

# Yazi + neovim
export EDITOR="nvim"
export VISUAL="nvim"
# =========================================
# 3. Thème & Plugins visuels
# =========================================
P10K_DIR="$HOME/dotfiles/zsh"
[[ -f "$P10K_DIR/powerlevel10k/powerlevel10k.zsh-theme" ]] && source "$P10K_DIR/powerlevel10k/powerlevel10k.zsh-theme"
[[ -f "$P10K_DIR/.p10k.zsh" ]] && source "$P10K_DIR/.p10k.zsh"

# Autosuggestions
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
[ -f "$HOME/dotfiles/devbox/.devbox/nix/profile/default/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$HOME/dotfiles/devbox/.devbox/nix/profile/default/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
bindkey '^E' autosuggest-accept

# Syntax highlighting (toujours en dernier)
[ -f "$HOME/dotfiles/devbox/.devbox/nix/profile/default/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$HOME/dotfiles/devbox/.devbox/nix/profile/default/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
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
alias za='zellij attach'
alias cc='clear'

# =========================================
# 5. Startup Interactive (Clear & Welcome)
# =========================================
if [[ -o interactive ]] && [[ -z "$STARTUP_DONE" ]]; then
  export STARTUP_DONE=1
  export KUBECONFIG="$HOME/.kube/config:/etc/rancher/k3s/k3s.yaml"
  
  clear
# On vérifie si neofetch est là avant de hurler une erreur
  if command -v neofetch >/dev/null 2>&1; then
    neofetch
  else
    echo "❌ neofetch n'est pas installé dans devbox.json"
  fi
  echo "🚀 Roof Kubernetes prêt !"
fi

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# To customize prompt, run `p10k configure` or edit ~/dotfiles/zsh/.p10k.zsh.
[[ ! -f ~/dotfiles/zsh/.p10k.zsh ]] || source ~/dotfiles/zsh/.p10k.zsh
