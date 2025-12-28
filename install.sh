#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Démarrage de l'initialisation Stateless Elfenec..."

DOTFILES_DIR="$(pwd)"
USER_NAME="$(whoami)"

# Chemins locaux pour Nix et Devbox
LOCAL_NIX="$DOTFILES_DIR/.nix"
LOCAL_DEVBOX="$DOTFILES_DIR/.devbox"

###############################################
# 1. Installation de Nix local si absent
###############################################
if [ ! -d "$LOCAL_NIX" ]; then
    echo "📦 Nix absent. Installation locale dans $LOCAL_NIX..."

    mkdir -p "$LOCAL_NIX"

    # Télécharger et installer Nix local
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon --no-modify-profile --prefix "$LOCAL_NIX"
fi

# Configurer les variables d'environnement pour la session
export NIX_USER_PROFILE_DIR="$LOCAL_NIX/profile"
export NIX_PATH="$LOCAL_NIX"
export PATH="$LOCAL_NIX/bin:$PATH"
export NIX_EXTRA_EXPERIMENTAL_FEATURES="nix-command flakes ca-derivations fetch-closure"

# Vérifier Nix
if ! command -v nix >/dev/null; then
    echo "❌ Nix non trouvé après installation."
    exit 1
fi

###############################################
# 2. Installation de Devbox locale si absent
###############################################
if [ ! -d "$LOCAL_DEVBOX" ]; then
    echo "📦 Installation de Devbox locale dans $LOCAL_DEVBOX..."
    curl -fsSL https://get.jetpack.io/devbox | bash -s -- --path "$LOCAL_DEVBOX"
fi

# Configurer Devbox pour la session
export DEVBOX_HOME="$LOCAL_DEVBOX"
export PATH="$LOCAL_DEVBOX/bin:$PATH"

if ! command -v devbox >/dev/null; then
    echo "❌ Devbox non trouvé après installation."
    exit 1
fi

###############################################
# 3. Créer et activer .envrc pour direnv
###############################################
ENVRC="$DOTFILES_DIR/.envrc"
if [ ! -f "$ENVRC" ]; then
    echo "use devbox" > "$ENVRC"
fi

if command -v direnv >/dev/null; then
    direnv allow "$DOTFILES_DIR"
fi

###############################################
# 4. Installation de direnv via Nix local
###############################################
if ! command -v direnv >/dev/null; then
    echo "📦 Installation de direnv via Nix local..."
    nix profile install nixpkgs#direnv
fi

###############################################
# 5. Oh My Zsh, P10k & plugins (optionnel)
###############################################
ZSH_CUSTOM="${ZSH_CUSTOM:-$DOTFILES_DIR/powerlevel10k}"
if [ ! -d "$ZSH_CUSTOM" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM"
fi

###############################################
# 6. Déploiement des dotfiles
###############################################
cp -f "$DOTFILES_DIR/.zshrc" "$DOTFILES_DIR/.p10k.zsh" "$DOTFILES_DIR/devbox.json" "$DOTFILES_DIR/"

###############################################
# 7. Installation des packages Devbox
###############################################
cd "$DOTFILES_DIR"
devbox install

###############################################
# 8. Finalisation
###############################################
echo ""
echo "✅ Setup terminé avec succès !"
echo "🚀 Tout est local dans $DOTFILES_DIR, aucun fichier créé en dehors."
echo "👉 Lance : zsh"
