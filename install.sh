#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Bootstrap stateless dotfiles"

###############################################
# 0. Git Identity (Stateless Setup)
###############################################
echo "👤 Configuring Git identity"
git config --global credential.helper store
git config --global user.email "elfenec75@gmail.com"
git config --global user.name "alfenec"
# Pour éviter les messages d'avertissement sur le mode de fusion
git config --global pull.rebase false

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

###############################################
# 0. Vérifier si Zsh est installé globalement
###############################################
if ! command -v zsh >/dev/null 2>&1; then
    echo "📦 Zsh non trouvé, installation via apt..."
    sudo apt update
    sudo apt install -y zsh
else
    echo "✅ Zsh déjà installé : $(zsh --version)"
fi

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
# 3. powerlevel10k (DANS le repo)
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
# 5. Devbox install (DANS le repo)
###############################################
echo "🧰 Installing devbox packages"
devbox install

###############################################
# 6. Configuration de l'Hôte (Idempotent)
###############################################
echo "🔗 Liaison du point d'entrée 'bis'..."

# La commande exacte qu'on veut dans le .bashrc
TARGET_ALIAS="alias bis='cd $DOTFILES_DIR && devbox run z'"

# On vérifie si l'alias existe déjà
if ! grep -qF "$TARGET_ALIAS" "$HOME/.bashrc"; then
    # On nettoie les anciennes versions potentielles de 'bis' pour éviter les doublons
    sed -i '/alias bis=/d' "$HOME/.bashrc"
    
    # On ajoute la version propre
    echo "$TARGET_ALIAS" >> "$HOME/.bashrc"
    echo "✅ Alias 'bis' configuré dans ~/.bashrc"
fi

###############################################
# 7. Lancement automatique (Stateless)
###############################################
echo "🚀 Bootstrap terminé. Entrée immédiate..."
# On ne fait pas de 'source', on 'exec' directement le bon process
cd "$DOTFILES_DIR"
exec devbox run z
