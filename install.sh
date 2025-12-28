#!/bin/bash

# Arrêter le script en cas d'erreur
set -e

echo "🚀 Démarrage de l'initialisation Stateless Elfenec..."

# 1. Installer Nix UNIQUEMENT s'il n'est pas sur le disque
if [ ! -d "/nix" ]; then
    echo "📦 Nix absent physiquement. Installation initiale..."
    
    # Nettoyage préventif complet (on vide TOUT ce qui peut bloquer)
    sudo rm -f /etc/bash.bashrc.backup-before-nix \
               /etc/zsh/zshrc.backup-before-nix \
               /etc/bashrc.backup-before-nix \
               /etc/zshrc.backup-before-nix \
               /etc/profile.backup-before-nix

    curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes --no-modify-profile
else
    echo "✅ Le dossier /nix existe déjà, on saute l'installation."
fi

# 2. Charger Nix de force pour la suite du script (MÊME si déjà installé)
if [ -e /etc/profile.d/nix.sh ]; then
    source /etc/profile.d/nix.sh
fi

# 2. Charger Nix pour la session actuelle (Indispensable pour la suite du script)
[ -e /etc/profile.d/nix.sh ] && source /etc/profile.d/nix.sh

# S'assurer que l'utilisateur peut utiliser Nix sans sudo
if [ -e /etc/profile.d/nix.sh ]; then
    source /etc/profile.d/nix.sh
    # On force un redémarrage du démon pour être sûr
    sudo systemctl restart nix-daemon.service || true
fi

# Fix des permissions si nécessaire
sudo chown -R $(whoami) /nix/var/nix/profiles/per-user/$(whoami) 2>/dev/null || true

# 2. Installer Devbox
if ! command -v devbox &> /dev/null; then
    echo "📦 Installation de Devbox..."
    curl -fsSL https://get.jetpack.io/devbox | bash
fi

# 3. Installer Oh My Zsh, P10k et les Plugins
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🐚 Installation de Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
mkdir -p "${ZSH_CUSTOM}/plugins"

echo "🔌 Installation des plugins ZSH..."
# Autosuggestions
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
# Syntax Highlighting
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
# You-should-use
[ ! -d "${ZSH_CUSTOM}/plugins/you-should-use" ] && \
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM}/plugins/you-should-use
# Powerlevel10k
[ ! -d "$HOME/powerlevel10k" ] && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

# 4. Déployer les fichiers de config
echo "📝 Déploiement des dotfiles..."
# On utilise -f pour forcer l'écrasement si les fichiers par défaut existent
cp -f .zshrc ~/.zshrc
cp -f .p10k.zsh ~/.p10k.zsh
cp -f devbox.json ~/devbox.json

# 5. Préchauffer Devbox
echo "🛠️ Installation des outils via Devbox (k9s, helm, btop, etc.)..."
# On s'assure d'être dans le bon dossier pour le devbox install
cd $HOME
sudo devbox install --allow-root

echo ""
echo "✅ Setup terminé avec succès !"
echo "👉 Tape 'zsh' pour activer ton cockpit."
echo "👉 Au premier lancement, Powerlevel10k te demandera peut-être de terminer la configuration."
