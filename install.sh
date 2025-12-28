#!/bin/bash

# Arrêter le script en cas d'erreur
set -e

echo "🚀 Démarrage de l'initialisation Stateless Elfenec..."

# 1. Installation de Nix
if [ ! -d "/nix" ]; then
    echo "📦 Nix absent. Installation initiale..."
    
    # Nettoyage préventif des backups bloquants
    sudo rm -f /etc/bash.bashrc.backup-before-nix \
               /etc/zsh/zshrc.backup-before-nix \
               /etc/bashrc.backup-before-nix \
               /etc/zshrc.backup-before-nix \
               /etc/profile.backup-before-nix

    curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes --no-modify-profile
else
    echo "✅ Nix est déjà présent sur le disque."
fi

# 2. Activation et Réparation des Permissions
echo "🔐 Configuration des accès Nix..."
[ -e /etc/profile.d/nix.sh ] && source /etc/profile.d/nix.sh

# Création forcée du profil utilisateur pour éviter l'erreur de "Lock"
sudo mkdir -p /nix/var/nix/profiles/per-user/$(whoami)
sudo chown -R $(whoami) /nix/var/nix/profiles/per-user/$(whoami)
sudo usermod -aG nixbld $(whoami) || true

# Redémarrage du démon pour valider les changements
sudo systemctl restart nix-daemon.service || true

# 3. Installation de Devbox
if ! command -v devbox &> /dev/null; then
    echo "📦 Installation de Devbox..."
    curl -fsSL https://get.jetpack.io/devbox | bash
fi

# 4. Oh My Zsh, P10k et Plugins
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🐚 Installation de Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
mkdir -p "${ZSH_CUSTOM}/plugins"

echo "🔌 Clonage des plugins ZSH..."
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
[ ! -d "${ZSH_CUSTOM}/plugins/you-should-use" ] && git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM}/plugins/you-should-use
[ ! -d "$HOME/powerlevel10k" ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

# 5. Déploiement des Dotfiles
echo "📝 Application des configurations (.zshrc, .p10k.zsh, devbox.json)..."
cp -f .zshrc ~/.zshrc
cp -f .p10k.zsh ~/.p10k.zsh
cp -f devbox.json ~/devbox.json

# 6. Installation des outils (Incrémental)
echo "🛠️ Synchronisation des outils via Devbox..."
cd $HOME
sudo devbox install

echo ""
echo "✅ Setup terminé avec succès !"
echo "👉 IMPORTANT : Tape 'newgrp nixbld' pour activer tes droits sans redémarrer."
echo "👉 Puis tape 'zsh' pour entrer dans ton cockpit."
