#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Démarrage de l'initialisation Stateless Elfenec..."

USER_NAME="$(whoami)"
DOTFILES_DIR="$HOME/dotfiles"
NIX_DIR="$DOTFILES_DIR/.nix"

###############################################
# 1. Installation de Nix local si absent
###############################################
if [ ! -d "$NIX_DIR" ]; then
    echo "📦 Nix absent. Installation locale dans $NIX_DIR..."
    mkdir -p "$NIX_DIR"
    curl -L https://releases.nixos.org/nix/latest/nix-2.33.0-x86_64-linux.tar.xz \
        -o "$DOTFILES_DIR/nix.tar.xz"
    tar -xf "$DOTFILES_DIR/nix.tar.xz" -C "$NIX_DIR" --strip-components=1
    rm "$DOTFILES_DIR/nix.tar.xz"
fi

# Ajouter Nix local au PATH
export PATH="$NIX_DIR/bin:$PATH"
[ -f "$NIX_DIR/etc/profile.d/nix.sh" ] && source "$NIX_DIR/etc/profile.d/nix.sh"

###############################################
# 2. Installation de Devbox local si absent
###############################################
DEVBOX_DIR="$DOTFILES_DIR/.devbox"
if [ ! -d "$DEVBOX_DIR" ]; then
    echo "📦 Installation de Devbox locale dans $DEVBOX_DIR..."
    mkdir -p "$DEVBOX_DIR"
    curl -fsSL https://get.jetpack.io/devbox | bash -s -- --path "$DEVBOX_DIR"
fi

# Source Devbox pour la session courante
export PATH="$DEVBOX_DIR/bin:$PATH"
[ -f "$DEVBOX_DIR/shellenv" ] && eval "$("$DEVBOX_DIR/bin/devbox" shellenv)"

###############################################
# 3. Installation de direnv via Nix
###############################################
if ! command -v direnv >/dev/null; then
    echo "📦 Installation de direnv via Nix..."
    nix --extra-experimental-features 'nix-command flakes ca-derivations fetch-closure' profile install nixpkgs#direnv
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
# 6. Création et activation de .envrc pour direnv
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
cd "$DOTFILES_DIR"
export NIX_EXTRA_EXPERIMENTAL_FEATURES="nix-command flakes ca-derivations fetch-closure"
devbox install

###############################################
# 8. Finalisation
###############################################
echo ""
echo "✅ Setup terminé avec succès !"
echo "🚀 Tape : zsh pour démarrer ta session Zsh avec Devbox et dotfiles prêts."
