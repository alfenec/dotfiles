#!/bin/bash

# Arrêter le script en cas d'erreur
set -e

echo "🚀 Démarrage de l'initialisation Stateless Elfenec..."

# 1. Installation de Nix avec auto-nettoyage
if ! command -v nix &> /dev/null; then
    echo "🧹 Nettoyage des anciens résidus Nix pour éviter les conflits..."
    
    # Suppression des fichiers de backup qui bloquent l'installeur
    sudo rm -f /etc/bash.bashrc.backup-before-nix
    sudo rm -f /etc/zsh/zshrc.backup-before-nix
    sudo rm -f /etc/zshrc.backup-before-nix
    sudo rm -f /etc/profile.backup-before-nix
    
    # Si un dossier /nix existe mais que la commande 'nix' ne répond pas, 
    # c'est que l'install est corrompue : on rase pour réinstaller proprement.
    if [ -d "/nix" ]; then
        echo "⚠️  Dossier /nix détecté mais inactif. Réinitialisation forcée..."
        sudo systemctl stop nix-daemon.service 2>/dev/null || true
        sudo rm -rf /nix /etc/nix /root/.nix-profile /root/.nix-defexpr /root/.nix-channels
    fi

    echo "📦 Installation de Nix (Multi-user)..."
    curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes --no-modify-profile
    
    # Chargement pour la session actuelle
    [ -e /etc/profile.d/nix.sh ] && source /etc/profile.d/nix.sh
else
    echo "✅ Nix est déjà opérationnel."
fi


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
devbox install

echo ""
echo "✅ Setup terminé avec succès !"
echo "👉 Tape 'zsh' pour activer ton cockpit."
echo "👉 Au premier lancement, Powerlevel10k te demandera peut-être de terminer la configuration."
