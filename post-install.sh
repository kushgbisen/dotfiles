#!/bin/bash
set -e

# Variables
GIT_NAME="kushgbisen"
GIT_EMAIL="kushgbisen@gmail.com"
DOTFILES_REPO="https://github.com/kushgbisen/dotfiles.git"

# Install packages 
sudo pacman -Syu --noconfirm --needed openssh stow zsh wget rsync wl-clipboard bluez bluez-utils alsa-utils pipewire pipewire-alsa pipewire-pulse sway xorg-xwayland alacritty firefox pamixer brightnessctl tree jq aria2 zip unzip less tree nano vim neovim git tmate tmux zsh gnupg

# Configure Git
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Generate SSH key (RSA 4096, no passphrase)
mkdir -p "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
  ssh-keygen -t rsa -b 4096 -N "" -f "$HOME/.ssh/id_rsa"
fi

# Generate GPG key (RSA 4096, no passphrase)
if ! gpg --list-secret-keys "$GIT_EMAIL" >/dev/null 2>&1; then
  gpg --batch --generate-key <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $GIT_NAME
Name-Email: $GIT_EMAIL
Expire-Date: 0
%no-protection
%commit
EOF
fi

# Clone dotfiles if not already present
if [ ! -d "$HOME/.dotfiles" ]; then
  git clone "$DOTFILES_REPO" "$HOME/.dotfiles"
fi

mkdir -p "$HOME/.config"
cd "$HOME/.dotfiles" && stow --adopt -vt "$HOME/.config" .config

echo "Post-installation done. Please reboot."
