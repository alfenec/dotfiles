#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Démarrage de l'initialisation Stateless Elfenec..."

USER_NAME="$(whoami)"
DOTFILES_DIR="$HOME/dotfiles"
NIX_LOCAL_DIR="$DOTFILES_DIR/.nix"
DEVBOX_LOCAL_DIR="$DOTFILES_DIR/.devbox"

###############################################
# 1. Installation de Nix single-user local
###############################################
if [ ! -d "$NIX_LOCAL_DIR" ]; then
    echo "📦 Nix absent. Installation locale dans $NIX_LOCAL_DIR..."
    mkdir -p "$NIX_LOCAL_DIR"
    export NIX_INSTALLER_NO_MODIFY_PROFILE=1
    curl -L https://releases.nixos.org/nix/nix-2.33.0/nix-2.33.0-aarch64-linux.tar.xz | tar -xJ -C "$NIX_LOCAL_DIR" --strip-components=1
fi

# Source Nix pour la session courante
export PATH="$NIX_LOCAL_DIR/bin:$PATH"

###############################################
# 2. Installation de Devbox local
###############################################
if ! command -v devbox >/dev/null; then
    echo "📦 Installation de Devbox locale..."
    mkdir -p "$DEVBOX_LOCAL_DIR"
    curl -fsSL https://get.jetpack.io/devbox | bash
fi

# Source Devbox local
eval "$(devbox shellenv)"

###############################################
# 3. Installation de direnv via Nix
###############################################
if ! command -v direnv >/dev/null; then
    echo "📦 Installation de direnv locale via Nix..."
    nix --extra-experimental-features 'nix-command flakes ca-derivations fetch-closure' profile install nixpkgs#direnv
fi

###############################################
# 4. Déploiement Zsh / P10k / plugins dans dotfiles
###############################################
ZSH_CUSTOM="$DOTFILES_DIR/.oh-my-zsh/custom"
mkdir -p "$ZSH_CUSTOM/plugins"

echo "🔌 Installation des plugins ZSH locaux..."
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ ! -d "$ZSH_CUSTOM/plugins/you-should-use" ] && \
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"
[ ! -d "$DOTFILES_DIR/powerlevel10k" ] && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$DOTFILES_DIR/powerlevel10k"

###############################################
# 5. Déploiement dotfiles dans le repo
###############################################
echo "📝 Déploiement des dotfiles..."
cp -f .zshrc "$DOTFILES_DIR/.zshrc"
cp -f .p10k.zsh "$DOTFILES_DIR/.p10k.zsh"
cp -f devbox.json "$DOTFILES_DIR/devbox.json"

###############################################
# 6. Création et activation de .envrc local
###############################################
ENVRC_FILE="$DOTFILES_DIR/.envrc"
if [ ! -f "$ENVRC_FILE" ]; then
    echo "use devbox" > "$ENVRC_FILE"
fi

if command -v direnv >/dev/null; then
    direnv allow "$DOTFILES_DIR"
fi

###############################################
# 7. Installation des packages Devbox
###############################################
export NIX_EXTRA_EXPERIMENTAL_FEATURES="nix-command flakes ca-derivations fetch-closure"
cd "$DOTFILES_DIR"
devbox install

###############################################
# 8. Finalisation
###############################################
echo ""
echo "✅ Setup terminé !"
echo "🚀 Pour démarrer Zsh local avec dotfiles :"
echo "   export ZSH=$DOTFILES_DIR/.oh-my-zsh && zsh"
