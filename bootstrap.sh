#!/bin/bash
set -e

# --- Variables ---
GIT_NAME="kushgbisen"
GIT_EMAIL="kushgbisen@gmail.com"
DOTFILES_REPO="https://github.com/kushgbisen/dotfiles.git"
AUR_BUILD_DIR="/tmp/aur_build_temp"

# --- Install base-devel (required for paru) ---
echo "--- Installing base-devel ---"
sudo pacman -Syu --noconfirm --needed base-devel git

# --- Install AUR Helper (paru) ---
echo "--- Building and installing paru-bin from AUR ---"
mkdir -p "$AUR_BUILD_DIR"
chmod 700 "$AUR_BUILD_DIR"
cd "$AUR_BUILD_DIR"
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si --noconfirm
cd ~
rm -rf "$AUR_BUILD_DIR"

# --- Install All Other Packages via paru ---
echo "--- Installing all other packages using paru ---"
# Includes packages from official repos and AUR
paru -S --noconfirm --needed \
    openssh \
    stow \
    zsh \
    wget \
    rsync \
    wl-clipboard \
    bluez \
    bluez-utils \
    alsa-utils \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    sway \
    xorg-xwayland \
    alacritty \
    firefox \
    pamixer \
    brightnessctl \
    tree \
    jq \
    aria2 \
    zip \
    unzip \
    less \
    nano \
    vim \
    neovim \
    tmate \
    tmux \
    gnupg \
    ttf-jetbrains-mono \
    ttf-firacode-nerd \
    noto-fonts-emoji \
    noto-fonts \
    swayidle \
    mako \
    waybar \
    playerctl \
    grim \
    slurp \
    libnotify \
    gsettings-desktop-schemas \
    thunar \
    neofetch \
    vi \
    rofi-lbonn-wayland-git \
    brave-bin \
    obsidian \
    telegram-desktop \
    gruvbox-material-gtk-theme-git \
    gruvbox-material-icon-theme-git \
    swaylock-effects

# --- Configure Git ---
echo "--- Configuring Git ---"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# --- Generate SSH key (RSA 4096, no passphrase) ---
echo "--- Generating SSH key ---"
mkdir -p "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
  ssh-keygen -t rsa -b 4096 -N "" -f "$HOME/.ssh/id_rsa"
fi

# --- Generate GPG key (RSA 4096, no passphrase) ---
echo "--- Generating GPG key ---"
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

# --- Clone Dotfiles if not already present ---
echo "--- Cloning dotfiles repository ---"
if [ ! -d "$HOME/.dotfiles" ]; then
  git clone "$DOTFILES_REPO" "$HOME/.dotfiles"
fi

# --- Stow Dotfiles ---
echo "--- Stowing dotfiles ---"
mkdir -p "$HOME/.config"
cd "$HOME/.dotfiles" && stow --adopt -vt "$HOME/.config" .config

# --- Final Steps ---
echo "--- Post-installation script finished ---"
echo "Please reboot for all changes to take effect."
