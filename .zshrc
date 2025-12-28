###############################################
# 0. Options Zsh
###############################################
setopt SHARE_HISTORY
HISTSIZE=10000
SAVEHIST=10000

###############################################
# 1. Nix / Devbox / direnv
###############################################
# Nix (si présent)
[ -e /etc/profile.d/nix.sh ] && source /etc/profile.d/nix.sh

# Devbox (si présent)
if command -v devbox >/dev/null 2>&1; then
  eval "$(devbox shellenv)"
fi

# direnv
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

###############################################
# 2. Powerlevel10k (DEPUIS DOTFILES)
###############################################
P10K_DIR="$HOME/dotfiles/powerlevel10k"

if [ -f "$P10K_DIR/powerlevel10k.zsh-theme" ]; then
  source "$P10K_DIR/powerlevel10k.zsh-theme"
fi

[[ -f "$HOME/dotfiles/.p10k.zsh" ]] && source "$HOME/dotfiles/.p10k.zsh"

###############################################
# 3. Plugins Zsh (SANS Oh My Zsh)
###############################################
# z
[ -f /usr/share/z/z.sh ] && source /usr/share/z/z.sh

# autosuggestions
if [ -f "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# syntax highlighting (DOIT ÊTRE EN DERNIER)
if [ -f "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

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

alias t2='tree -L 2'
alias t3='tree -L 3'

###############################################
# 6. FZF
###############################################
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
