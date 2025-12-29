# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

###############################################
# 0. Options Zsh
###############################################
setopt SHARE_HISTORY
HISTSIZE=10000
SAVEHIST=10000

###############################################
# 1. Nix / Devbox / direnv
###############################################
if command -v devbox >/dev/null 2>&1 && [[ -f ~/dotfiles/devbox.json ]]; then
  pushd ~/dotfiles >/dev/null
  eval "$(devbox shellenv)"
  popd >/dev/null
fi

cd ~/gitops

# Nix (si présent)
[ -e /etc/profile.d/nix.sh ] && source /etc/profile.d/nix.sh

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

###############################################
# 5. Alias Kubernetes & Ops
###############################################
# Ne lancer que dans un shell interactif
if [[ -o interactive ]]; then

  # Affichage système
  command -v neofetch >/dev/null 2>&1 && neofetch

  # Kubernetes
  export KUBECONFIG="$HOME/.kube/config:/etc/rancher/k3s/k3s.yaml"

  # Message de bienvenue
  echo "🚀 Roof Kubernetes prêt !"

  #############################################
  # Alias Dev / Ops
  #############################################
  alias k='kubecolor'
  alias kubectl='kubecolor'
  alias mc='mcli'
  alias kn='k9s'
  alias ctx='kubectx'
  alias ns='kubens'
  alias t='task'
  alias t2='tree -L 2'
  alias t3='tree -L 3'
  alias bis='neofetch'

fi

###############################################
# 6. FZF
###############################################
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

if [ -e /home/elfenec/.nix-profile/etc/profile.d/nix.sh ]; then . /home/elfenec/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# To customize prompt, run `p10k configure` or edit ~/dotfiles/.p10k.zsh.
[[ ! -f ~/dotfiles/.p10k.zsh ]] || source ~/dotfiles/.p10k.zsh

