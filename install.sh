#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Bootstrap stateless dotfiles"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

###############################################
# 1. Nix — installation locale, non intrusive
###############################################
if ! command -v nix >/dev/null; then
  echo "📦 Installing Nix (single-user, non-intrusive)"
  curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
fi

# Charger Nix pour la session courante
if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  source "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

###############################################
# 2. Devbox (user-space, via script officiel)
###############################################
if ! command -v devbox >/dev/null; then
  echo "📦 Installing Devbox"
  curl -fsSL https://get.jetpack.io/devbox | bash
fi

###############################################
# 3. Powerlevel10k (DANS le repo)
###############################################
if [ ! -d "$DOTFILES_DIR/powerlevel10k" ]; then
  echo "🎨 Installing powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$DOTFILES_DIR/powerlevel10k"
fi

###############################################
# 4. Zsh config (symlinks UNIQUEMENT)
###############################################
link() {
  local src="$1"
  local dst="$2"
  if [ ! -e "$dst" ]; then
    ln -s "$src" "$dst"
  fi
}

link "$DOTFILES_DIR/.zshrc"   "$HOME/.zshrc"
link "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

###############################################
# 5. Installer zsh via Devbox et packages
###############################################
echo "🧰 Installing devbox packages"
devbox add nixpkgs.zsh
devbox install

# Optionnel : afficher le chemin de zsh Devbox
DEVBOX_ZSH="$(devbox which zsh)"
echo "📌 Zsh est disponible via Devbox : $DEVBOX_ZSH"
echo "Pour lancer zsh : $DEVBOX_ZSH"

###############################################
# 6. Fin
###############################################
echo ""
echo "✅ Bootstrap terminé"
echo "👉 run: $DEVBOX_ZSH"

