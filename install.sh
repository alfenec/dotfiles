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
# 3. Devbox (User-space)
###############################################
if ! command -v devbox >/dev/null; then
    echo "📦 Installing Devbox"
    curl -fsSL https://get.jetpack.io/devbox | bash
fi

###############################################
# 4. Powerlevel10k (Installation sans Git si possible)
###############################################
if [ ! -d "$DOTFILES_DIR/powerlevel10k" ]; then
    echo "🎨 Installing powerlevel10k..."
    # On utilise curl pour rester "stateless" et léger
    mkdir -p "$DOTFILES_DIR/powerlevel10k"
    curl -L https://github.com/romkatv/powerlevel10k/archive/refs/heads/master.tar.gz | \
    tar -xz -C "$DOTFILES_DIR/powerlevel10k" --strip-components=1
fi

###############################################
# 5. Zsh config (Symlinks Idempotents)
###############################################
link_file() {
    local src="$1"
    local dst="$2"
    if [ -L "$dst" ]; then
        rm "$dst" # On recrée le lien pour être sûr qu'il est à jour
    elif [ -f "$dst" ]; then
        mv "$dst" "${dst}.bak" # Backup si un vrai fichier existe
    fi
    ln -s "$src" "$dst"
    echo "🔗 Link créé : $dst"
}

link_file "$DOTFILES_DIR/.zshrc"   "$HOME/.zshrc"
link_file "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

###############################################
# 6. Devbox Install (Sync des packages)
###############################################
echo "🧰 Synchronisation des packages Devbox..."
devbox install

###############################################
# 7. Finalisation
###############################################
echo "🚀 Setup terminé !"

if [ -d "$DOTFILES_DIR" ]; then
    pushd "$DOTFILES_DIR" > /dev/null
    eval "$(devbox shellenv)"
    popd > /dev/null
fi

if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi

# On remplace le shell actuel par Zsh
exec zsh
