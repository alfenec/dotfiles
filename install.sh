#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Démarrage de l'initialisation Stateless Elfenec..."

USER_NAME="$(whoami)"

###############################################
# 1. Installation de Nix multi-user si absent
###############################################
if [ ! -d "/nix" ]; then
    echo "📦 Nix absent. Installation initiale..."
    
    # Nettoyage préventif de backups
    sudo rm -f \
        /etc/bash.bashrc.backup-before-nix \
        /etc/zsh/zshrc.backup-before-nix \
        /etc/bashrc.backup-before-nix \
        /etc/zshrc.backup-before-nix \
        /etc/profile.backup-before-nix

    curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes --no-modify-profile
else
    echo "✅ Nix déjà présent."
fi

# Source Nix pour la session courante
[ -e /etc/profile.d/nix.sh ] && source /etc/profile.d/nix.sh

###############################################
# 2. Configuration Nix multi-user + trusted user
###############################################
sudo mkdir -p /etc/nix/nix.conf.d
sudo tee /etc/nix/nix.conf.d/00-multi-user.conf >/dev/null <<EOF
allowed-users = *
trusted-users = root ${USER_NAME}
build-users-group = nixbld
sandbox = true
experimental-features = nix-command flakes ca-derivations fetch-closure
EOF

# Permissions correctes
sudo chown -R root:nixbld /nix/var/nix
sudo chmod 1775 /nix/var/nix
sudo chmod 1775 /nix/var/nix/db
sudo chmod 1775 /nix/var/nix/temproots

# Nettoyage locks temporaires
sudo rm -f /nix/var/nix/db/big-lock
sudo rm -rf /nix/var/nix/temproots/*

# Ajout de l'utilisateur au groupe nixbld
sudo usermod -aG nixbld "${USER_NAME}" || true

# Redémarrage du démon
sudo systemctl restart nix-daemon || true

###############################################
# 3. Installation de Devbox si absent
###############################################
if ! command -v devbox >/dev/null; then
    echo "📦 Installation de Devbox..."
    curl -fsSL https://get.jetpack.io/devbox | bash
fi

# Source Devbox pour la session courante
if command -v devbox >/dev/null; then
    eval "$(devbox shellenv)"
fi

###############################################
# 4. Installation de direnv via Devbox/Nix
###############################################
if ! command -v direnv >/dev/null; then
    echo "📦 Installation de direnv via Nix..."
    nix profile install nixpkgs#direnv
fi

###############################################
# 5. Oh My Zsh, P10k & plugins
###############################################
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🐚 Installation de Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "${ZSH_CUSTOM}/plugins"

echo "🔌 Installation des plugins ZSH..."
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
[ ! -d "${ZSH_CUSTOM}/plugins/you-should-use" ] && \
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "${ZSH_CUSTOM}/plugins/you-should-use"
[ ! -d "$HOME/powerlevel10k" ] && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"

###############################################
# 6. Déploiement des dotfiles
###############################################
echo "📝 Déploiement des dotfiles..."
cp -f .zshrc "$HOME/.zshrc"
cp -f .p10k.zsh "$HOME/.p10k.zsh"
cp -f devbox.json "$HOME/devbox.json"

###############################################
# 7. Création et activation de .envrc
###############################################
if [ ! -f "$HOME/dotfiles/.envrc" ]; then
    echo "use devbox" > "$HOME/dotfiles/.envrc"
fi

# Autorise automatiquement .envrc pour direnv
if command -v direnv >/dev/null; then
    direnv allow "$HOME/dotfiles"
fi

###############################################
# 8. Installation des packages Devbox
###############################################
cd "$HOME/dotfiles"
devbox install

###############################################
# 9. Finalisation
###############################################
echo ""
echo "✅ Setup terminé avec succès !"
echo "🚀 tape : zsh "
