#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Bootstrap stateless dotfiles (Unified Mac/Linux)"

# Détection de l'OS
OS_TYPE=$(uname)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

###############################################
# 0. Git Identity (Stateless Setup)
###############################################
#echo "👤 Configuring Git identity"
git config --global user.email "elfenec75@gmail.com"
git config --global user.name "alfenec"
git config --global pull.rebase false

###############################################
# 1. Installation de Zsh (si manquant)
###############################################
if ! command -v zsh >/dev/null 2>&1; then
  if [ "$OS_TYPE" == "Linux" ]; then
    echo "📦 Zsh non trouvé, installation via apt..."
    sudo apt update && sudo apt install -y zsh
  else
    echo "❌ Zsh devrait être natif sur Mac. Vérifiez votre installation."
  fi
else
  echo "✅ Zsh déjà installé : $(zsh --version)"
fi

###############################################
# 2. Nix — Installation robuste
###############################################
echo "🔍 Vérification de Nix..."
if ! command -v nix >/dev/null; then
  echo "📦 Installation de Nix via Determinate Systems (recommandé)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

  # Source immédiate pour la suite du script
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi
else
  echo "✅ Nix est déjà présent."
fi

###############################################
# 2.5 Docker — Engine + CLI (stateless / idempotent)
###############################################
echo "🐳 Vérification de Docker..."

if ! command -v docker >/dev/null 2>&1; then
  echo "📦 Docker non trouvé, installation via script officiel..."

  # Installer les dépendances nécessaires
  sudo apt update
  sudo apt install -y ca-certificates curl gnupg lsb-release

  # Téléchargement du script officiel Docker
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh

  # Nettoyage
  rm -f get-docker.sh

  echo "✅ Docker installé."
else
  echo "✅ Docker déjà présent : $(docker --version)"
fi

# Ajout de l'utilisateur au groupe docker si nécessaire
if groups "$USER" | grep -q "\bdocker\b"; then
  echo "✅ L'utilisateur $USER fait déjà partie du groupe docker."
else
  echo "➕ Ajout de $USER au groupe docker..."
  sudo usermod -aG docker "$USER"
  echo "⚠️ Pour que l'accès Docker sans sudo soit effectif, déconnectez-vous et reconnectez-vous."
fi

# Test rapide de Docker si c'est la première installation
if ! docker info >/dev/null 2>&1; then
  echo "🔧 Test rapide Docker..."
  docker run --rm hello-world || echo "❌ Impossible d'exécuter hello-world (à vérifier après reconnexion)."
fi

echo "ℹ️ Commandes Docker de base :"
echo "   docker ps      → lister les conteneurs en cours"
echo "   docker images  → lister les images locales"
echo "   docker run -d --name mon_nginx -p 80:80 nginx  → lancer un nginx de test"

###############################################
# 3. Devbox (User-space)
###############################################
if ! command -v devbox >/dev/null; then
  echo "📦 Installing Devbox"
  curl -fsSL https://get.jetpack.io/devbox | bash
fi

###############################################
# 4. Powerlevel10k (Installation sans Git si possible)
###############################################
P10K_DIR="$DOTFILES_DIR/zsh/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "🎨 Installing powerlevel10k..."
  mkdir -p "$P10K_DIR"
  curl -L https://github.com/romkatv/powerlevel10k/archive/refs/heads/master.tar.gz |
    tar -xz -C "$P10K_DIR" --strip-components=1
fi

################################################
# 5. Devbox Install (Sync des packages)
################################################
echo "🧰 Synchronisation des packages Devbox..."
DEVBOX_CONFIG_DIR="$DOTFILES_DIR/devbox"

if [ -d "$DEVBOX_CONFIG_DIR" ]; then
  echo "🧰 Synchronisation des packages Devbox..."
  pushd "$DEVBOX_CONFIG_DIR" >/dev/null
  devbox install
  # CRITIQUE : On active l'environnement ici pour avoir accès à 'stow'
  eval "$(devbox shellenv)"
  popd >/dev/null
else
  echo "❌ Erreur : dossier $DEVBOX_CONFIG_DIR introuvable."
  exit 1
fi

###############################################
# 6. Automatisation de GNU Stow
###############################################
if command -v stow >/dev/null 2>&1; then
  echo "🔗 Création des liens symboliques via Stow..."

  # ON ENLÈVE "ssh" DE CETTE LISTE
  modules=("zsh" "nvim" "zellij" "yazi" "git")

  for module in "${modules[@]}"; do
    if [ -d "$DOTFILES_DIR/$module" ]; then
      echo "  -> Setup $module..."

      # Nettoyage automatique
      [ "$module" == "zsh" ] && rm -f "$HOME/.zshrc" "$HOME/.p10k.zsh"
      [ "$module" == "git" ] && rm -f "$HOME/.gitconfig"

      stow -R "$module"
    fi
  done

  # Gestion MANUELLE et SÉCURISÉE du config SSH (optionnel)
  if [ -f "$DOTFILES_DIR/ssh/.ssh/config" ]; then
    echo "  -> Setup SSH config (link only)..."
    mkdir -p "$HOME/.ssh"
    # On ne lie que le fichier de config, pas tout le dossier
    ln -sf "$DOTFILES_DIR/ssh/.ssh/config" "$HOME/.ssh/config"
  fi
fi

###############################################
# 7. Finalisation
###############################################
echo "🚀 Setup terminé !"

if command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi

# On remplace le shell actuel par Zsh
exec zsh
