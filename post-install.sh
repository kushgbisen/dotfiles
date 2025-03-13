#!/bin/bash
set -e

# Variables
GIT_NAME="kushgbisen"
GIT_EMAIL="kushgbisen@gmail.com"
DOTFILES_REPO="https://github.com/kushgbisen/dotfiles.git"

# Install packages in one go
sudo pacman -Syu --noconfirm --needed \
  openssh stow zsh wget rsync wl-clipboard \
  bluez bluez-utils alsa-utils pipewire pipewire-alsa pipewire-pulse \
  sway xorg-xwayland foot firefox pamixer brightnessctl

# Append Wayland environment variables
echo -e "\nMOZ_ENABLE_WAYLAND=1\nLIBSEAT_BACKEND=logind" | sudo tee -a /etc/environment >/dev/null

# Configure Git
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Clone dotfiles if not already present
if [ ! -d "$HOME/.dotfiles" ]; then
  git clone "$DOTFILES_REPO" "$HOME/.dotfiles"
fi

mkdir -p "$HOME/.config"
cd "$HOME/.dotfiles" && stow --adopt -vt "$HOME/.config" .config

echo "Post-installation done. Please reboot."
