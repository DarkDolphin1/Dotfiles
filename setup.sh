#!/bin/bash

# setup.sh - Arch Linux Environment Setup
# Abort on error
set -e

echo ">>> Updating system repositories..."
sudo pacman -Syu --needed --noconfirm base-devel git

# 1. Build yay from source
if ! command -v yay &>/dev/null; then
  echo ">>> Building yay from source..."
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  echo ">>> yay is already installed."
fi

# 2. Swap file and ZRAM Setup (using zram-generator for modern Arch)
echo ">>> Make a swap file [Size/n]? (Default is n)"
//setup swapfile here

echo ">>> Setting up ZRAM..."
sudo pacman -S --needed --noconfirm zram-generator

# Create zram-generator config
# This defaults to zstd compression and 50% of RAM size (good for your 16GB setup)
echo ">>> Configuring ZRAM "
echo ">> Choose Size (Default -> RAM size )"
echo ">> Choose comppression-algorithm (Default -> zstd) "

sudo bash -c 'cat > /etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = ram 
compression-algorithm = zstd
EOF'

sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service
echo ">>> ZRAM Status:"
zramctl

# 3. Build asusctl (using yay)
echo ">>> Installing Asusctl , building from source "
yay -S --noconfirm asusctl
# Enable the service
sudo systemctl enable --now asusd

PKGS=(
  "btop"
  "fastfetch"
  "fortune-mod"
  "cowsay"
  "lolcat"
  "bat"
  "yazi"
  "nvim"
  "fzf"
  "ncdu"
  "dust"
  "helix"
)

echo ">>> Installing additional packages: ${PKGS[*]}"
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

DEVTOOLS=("rust" "python" "node" "git" "llvm" "clang" "lazygit")
echo ">>> Installling Dev tools "
sudo pacman -S --needed --noconfirm "${DEVTOOLS[@]}"
yay -S visual-studio-code-bin --noconfirm --needed

echo ">>> Setup complete! Please restart your shell."
