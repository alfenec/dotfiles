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
  # shellcheck disable=SC1090
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
# 3. direnv (via Nix profile USER)
###############################################
if ! command -v direnv >/dev/null; then
  echo "📦 Installing direnv (Nix profile)"
  nix profile install nixpkgs#direnv
fi

###############################################
# 4. powerlevel10k (DANS le repo)
###############################################
if [ ! -d "$DOTFILES_DIR/powerlevel10k" ]; then
  echo "🎨 Installing powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$DOTFILES_DIR/powerlevel10k"
fi

###############################################
# 5. Zsh config (symlinks UNIQUEMENT)
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
# 6. Devbox install (DANS le repo)
###############################################
echo "🧰 Installing devbox packages"
devbox install

###############################################
# 7. Fin
###############################################
echo ""
echo "✅ Bootstrap terminé"
echo "👉 run once: direnv allow"
echo "👉 then: zsh"
