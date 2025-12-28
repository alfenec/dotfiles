#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Démarrage de l'initialisation Stateless Elfenec..."

USER_NAME="$(whoami)"

###############################################
# 1. Installation de Nix single-user si absent
###############################################
if [ ! -d "$HOME/.nix-profile" ]; then
    echo "📦 Nix absent. Installation initiale (single-user)..."

    # Nettoyage préventif de backups
    rm -f \
        "$HOME/.bashrc.backup-before-nix" \
        "$HOME/.zshrc.backup-before-nix" \
        "$HOME/.profile.backup-before-nix"

    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
else
    echo "✅ Nix déjà présent."
fi

# Source Nix pour la session courante
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    source "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

###############################################
# 2. Installation de Devbox si absent
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
# 3. Installation de direnv via Nix
###############################################
if ! command -v direnv >/dev/null; then
    echo "📦 Installation de direnv via Nix..."
    nix profile install nixpkgs#direnv \
        --extra-experimental-features 'nix-command flakes ca-derivations fetch-closure'
fi

###############################################
# 4. Oh My Zsh, P10k & plugins
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
# 5. Déploiement des dotfiles
###############################################
echo "📝 Déploiement des dotfiles..."
cp -f .zshrc "$HOME/.zshrc"
cp -f .p10k.zsh "$HOME/.p10k.zsh"
cp -f devbox.json "$HOME/devbox.json"

###############################################
# 6. Création et activation de .envrc
###############################################
if [ ! -f "$HOME/dotfiles/.envrc" ]; then
    echo "use devbox" > "$HOME/dotfiles/.envrc"
fi

# Autorise automatiquement .envrc pour direnv
if command -v direnv >/dev/null; then
    direnv allow "$HOME/dotfiles"
fi

###############################################
# 7. Installation des packages Devbox
###############################################
export NIX_EXTRA_EXPERIMENTAL_FEATURES="nix-command flakes ca-derivations fetch-closure"

cd "$HOME/dotfiles"
devbox install

###############################################
# 8. Finalisation
###############################################
echo ""
echo "✅ Setup terminé avec succès !"
echo "🚀 tape : zsh "
