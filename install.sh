#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Démarrage de l'initialisation Stateless Elfenec..."

USER_NAME="$(whoami)"

###############################################
# 1. Installation de Nix (daemon)
###############################################
if [ ! -d "/nix" ]; then
  echo "📦 Nix absent. Installation initiale..."

  sudo rm -f \
    /etc/bash.bashrc.backup-before-nix \
    /etc/zsh/zshrc.backup-before-nix \
    /etc/bashrc.backup-before-nix \
    /etc/zshrc.backup-before-nix \
    /etc/profile.backup-before-nix

  curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes --no-modify-profile
else
  echo "✅ Nix est déjà présent."
fi

###############################################
# 2. Activation Nix (session courante)
###############################################
if [ -e /etc/profile.d/nix.sh ]; then
  source /etc/profile.d/nix.sh
fi

###############################################
# 3. Configuration Nix PROPRE (trusted user)
###############################################
echo "🔐 Configuration des accès Nix..."

sudo mkdir -p /etc/nix/nix.conf.d

sudo tee /etc/nix/nix.conf.d/10-elfenec.conf >/dev/null <<EOF
trusted-users = root ${USER_NAME}
allowed-users = *
experimental-features = nix-command flakes ca-derivations fetch-closure
EOF

# Permissions STRICTEMENT nécessaires
sudo chown root:nixbld /nix/var/nix/db
sudo chmod 775 /nix/var/nix/db

# Groupe nixbld
sudo usermod -aG nixbld "${USER_NAME}" || true

sudo systemctl restart nix-daemon.service

###############################################
# 4. Installation de Devbox (USER, JAMAIS sudo)
###############################################
if ! command -v devbox >/dev/null; then
  echo "📦 Installation de Devbox..."
  curl -fsSL https://get.jetpack.io/devbox | bash
fi

###############################################
# 5. Oh My Zsh, P10k & Plugins
###############################################
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "🐚 Installation de Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "${ZSH_CUSTOM}/plugins"

echo "🔌 Installation des plugins ZSH..."

[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"

[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"

[ ! -d "${ZSH_CUSTOM}/plugins/you-should-use" ] && \
  git clone https://github.com/MichaelAquilina/zsh-you-should-use.git \
  "${ZSH_CUSTOM}/plugins/you-should-use"

[ ! -d "$HOME/powerlevel10k" ] && \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "$HOME/powerlevel10k"

###############################################
# 6. Déploiement des dotfiles
###############################################
echo "📝 Déploiement des dotfiles..."

cp -f .zshrc "$HOME/.zshrc"
cp -f .p10k.zsh "$HOME/.p10k.zsh"
cp -f devbox.json "$HOME/devbox.json"

###############################################
# 7. Installation des outils via Devbox
###############################################
echo "🛠️ Installation des outils Devbox..."

cd "$HOME"
devbox install

###############################################
# 8. Finalisation session
###############################################
echo ""
echo "✅ Setup terminé avec succès !"
echo "👉 Exécute maintenant : newgrp nixbld"
echo "👉 Puis : zsh"

