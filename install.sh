#!/bin/bash
set -e

echo "KARBS - Arch Linux Installer"

# Defaults
DEVICE="/dev/nvme0n1"
SWAP_SIZE="8192MiB"
TIMEZONE="Asia/Kolkata"
LOCALE="en_US.UTF-8"
LOCALE_GEN="en_US.UTF-8 UTF-8"
KEYMAP="us"
USER_NAME="kushgbisen"
HOSTNAME="archlinux"
KERNEL="linux-zen" # Options: linux, linux-zen, linux-lts, linux-hardened
DRIVER="amd"       # Options: amd, intel, nouveau

# Get installation device
lsblk
read -p "Installation device [${DEVICE}]: " inp
if [ -n "$inp" ]; then
  DEVICE="$inp"
fi

# Set partition suffix if NVMe
if echo "$DEVICE" | grep -q "nvme"; then
  PART_SUFFIX="p"
else
  PART_SUFFIX=""
fi

# Determine UEFI or BIOS
if [ -d /sys/firmware/efi/efivars ]; then
  PARTITION_MODE="uefi"
else
  PARTITION_MODE="bios"
fi

# Get username and hostname
read -p "Username [${USER_NAME}]: " inp
if [ -n "$inp" ]; then
  USER_NAME="$inp"
fi
read -p "Hostname [${HOSTNAME}]: " inp
if [ -n "$inp" ]; then
  HOSTNAME="$inp"
fi

# Get passwords
while true; do
  read -s -p "Root password: " ROOT_PASS
  echo
  read -s -p "Confirm root password: " ROOT_PASS2
  echo
  [ "$ROOT_PASS" = "$ROOT_PASS2" ] && break || echo "Passwords do not match."
done

while true; do
  read -s -p "User password: " USER_PASS
  echo
  read -s -p "Confirm user password: " USER_PASS2
  echo
  [ "$USER_PASS" = "$USER_PASS2" ] && break || echo "Passwords do not match."
done

# Git info
read -p "Git name [${USER_NAME}]: " inp
[ -n "$inp" ] && GIT_NAME="$inp" || GIT_NAME="$USER_NAME"
read -p "Git email: " GIT_EMAIL

# Choose kernel
echo "Choose kernel: 1) linux 2) linux-zen 3) linux-lts 4) linux-hardened"
read -p "Option [2]: " kopt
case $kopt in
1) KERNEL="linux" ;;
3) KERNEL="linux-lts" ;;
4) KERNEL="linux-hardened" ;;
*) KERNEL="linux-zen" ;;
esac

# Choose graphics driver
echo "Choose graphics driver: 1) AMD 2) Intel 3) Nouveau"
read -p "Option [1]: " dopt
case $dopt in
2) DRIVER="intel" ;;
3) DRIVER="nouveau" ;;
*) DRIVER="amd" ;;
esac

echo "Using: $DEVICE, Mode: $PARTITION_MODE, Kernel: $KERNEL, Driver: $DRIVER, User: $USER_NAME, Host: $HOSTNAME"
read -p "Proceed with installation? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy] ]]; then
  echo "Cancelled."
  exit 1
fi

# Prepare system
loadkeys "$KEYMAP"
timedatectl set-ntp true
timedatectl set-timezone "$TIMEZONE"
mountpoint -q /mnt && umount -R /mnt || true

# Partition disk
echo "Partitioning disk..."
if [ "$PARTITION_MODE" = "uefi" ]; then
  parted -s "$DEVICE" mklabel gpt
  parted -s "$DEVICE" mkpart ESP fat32 1MiB 261MiB
  parted -s "$DEVICE" mkpart swap linux-swap 261MiB "$SWAP_SIZE"
  parted -s "$DEVICE" mkpart primary ext4 "$SWAP_SIZE" 100%
  parted -s "$DEVICE" set 1 esp on
  PART_BOOT="$DEVICE$PART_SUFFIX""1"
  PART_SWAP="$DEVICE$PART_SUFFIX""2"
  PART_ROOT="$DEVICE$PART_SUFFIX""3"
  mkfs.fat -F32 "$PART_BOOT"
  mkswap "$PART_SWAP"
else
  parted -s "$DEVICE" mklabel msdos
  parted -s "$DEVICE" mkpart primary ext4 4MiB 512MiB
  parted -s "$DEVICE" mkpart primary ext4 512MiB 100%
  parted -s "$DEVICE" set 1 boot on
  PART_BOOT="$DEVICE$PART_SUFFIX""1"
  PART_ROOT="$DEVICE$PART_SUFFIX""2"
  mkfs.fat -F32 "$PART_BOOT"
fi
mkfs.ext4 -F "$PART_ROOT"

mount "$PART_ROOT" /mnt
if [ "$PARTITION_MODE" = "uefi" ]; then
  swapon "$PART_SWAP"
  mkdir -p /mnt/boot/efi
  mount "$PART_BOOT" /mnt/boot/efi
else
  mkdir -p /mnt/boot
  mount "$PART_BOOT" /mnt/boot
fi

# Install base system
pacstrap /mnt base base-devel "$KERNEL" linux-firmware networkmanager ly git
genfstab -U /mnt >>/mnt/etc/fstab

# Configure system
arch-chroot /mnt ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
arch-chroot /mnt hwclock --systohc
echo "$LOCALE_GEN" >/mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=$LOCALE" >/mnt/etc/locale.conf
echo "KEYMAP=$KEYMAP" >/mnt/etc/vconsole.conf
echo "$HOSTNAME" >/mnt/etc/hostname
cat >/mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF

# Install graphics drivers
if [ "$DRIVER" = "nouveau" ]; then
  arch-chroot /mnt pacman -Syu --noconfirm --needed mesa
elif [ "$DRIVER" = "intel" ]; then
  arch-chroot /mnt pacman -Syu --noconfirm --needed mesa vulkan-intel xf86-video-intel
else
  arch-chroot /mnt pacman -Syu --noconfirm --needed mesa vulkan-radeon xf86-video-amdgpu libva-mesa-driver mesa-vdpau
fi

# Set passwords and create user
echo "root:$ROOT_PASS" | arch-chroot /mnt chpasswd
arch-chroot /mnt useradd -m -G wheel "$USER_NAME"
echo "$USER_NAME:$USER_PASS" | arch-chroot /mnt chpasswd
echo "$USER_NAME ALL=(ALL) ALL" >/mnt/etc/sudoers.d/"$USER_NAME"
chmod 440 /mnt/etc/sudoers.d/"$USER_NAME"
arch-chroot /mnt pacman -Syu --noconfirm --needed sudo nano
arch-chroot /mnt systemctl enable NetworkManager.service
arch-chroot /mnt systemctl enable ly.service

# Install bootloader
arch-chroot /mnt pacman -Syu --noconfirm --needed grub efibootmgr
if grep -q Intel /proc/cpuinfo; then
  arch-chroot /mnt pacman -Syu --noconfirm --needed intel-ucode
else
  arch-chroot /mnt pacman -Syu --noconfirm --needed amd-ucode
fi
if [ "$PARTITION_MODE" = "uefi" ]; then
  arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
else
  arch-chroot /mnt grub-install --target=i386-pc "$DEVICE"
fi
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot /mnt mkinitcpio -P

# Copy post-install script
cp ./post-install.sh /mnt/home/"$USER_NAME"/post-install.sh
chmod +x /mnt/home/"$USER_NAME"/post-install.sh
arch-chroot /mnt chown "$USER_NAME":"$USER_NAME" /home/"$USER_NAME"/post-install.sh

echo "Installation complete. Unmount /mnt and reboot."
