#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
    echo "ERROR: Do not run this script as root or with sudo!"
    exit 1
fi

shopt -s dotglob

CONFIG="$HOME/.config"

delete_old() {
    for FOLDER in */; do
        NOME="${FOLDER%/}"
        if [[ "$NOME" == ".git" ]]; then
            continue
        fi

        if [[ -d "$CONFIG/$NOME" ]]; then
            rm -rf "$CONFIG/$NOME"
        fi
    done
}

check_packages() {
    local PACK=("$@")

    for pkg in "${PACK[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            sudo pacman -S --noconfirm "$pkg"
        fi
    done
}

DEP=(
    "hyprland"
    "waybar"
    "wofi"
    "alacritty"
    "swayosd-git"
    "wallust"
)

run_install() {
    cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
    
    delete_old
    check_packages "${DEP[@]}"
    cp ./select-wallpaper $HOME/.local/bin/
    mkdir -p "$HOME/Imagens/wallpapers"
    
    for FOLDER in */; do
        NOME="${FOLDER%/}"
        if [[ "$NOME" == ".git" ]]; then
            continue
        fi
	if [[ "$NOME" == "wallpapers" ]]; then
		cp -r "$FOLDER" "$HOME/Imagens/wallpapers"
		continue
	fi
        cp -r "$FOLDER" "$CONFIG/"
    done
}

echo "-- JV Dots Installer --"
echo "WARNING: Do not execute this script as root or with sudo."
echo "WARNING: The installer will rebuild these folders, deleting their contents:"
echo "~/.config/ (hypr, waybar, wofi, wallust, alacritty, etc.)"
echo "The script will also create ~/Imagens/wallpapers if it does not exist."
echo

read -r -p "Do you accept this? [Y/n] " RESP
RESP="${RESP,,}"
RESP="${RESP:-y}"

if [[ "$RESP" == "y" || "$RESP" == "yes" ]]; then
    run_install
else
    exit 1
fi
