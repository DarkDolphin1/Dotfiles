#!/bin/bash

# setup.sh - Arch Linux Environment Setup
# Abort on error
set -e

echo ">>> Make sure you are running this from your Home Directory without root priv "
cd ~ 

echo ">>> Updating system repositories..."

pacman_install(){
    sudo pacman -Syu --needed --noconfirm "${@}"
}

pacman_install base-devel git 

yay_install(){
    yay -S --needed --noconfirm "${@}"
}

git_clone(){
    local url=$1
    git clone "$url" 
}

# 1. Build yay from source
if ! command -v yay &>/dev/null; then
  echo ">>> Building yay from source..."
  git_Clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  echo ">>> yay is already installed."
fi

# 2. Swap file and ZRAM Setup (using zram-generator for modern Arch)
echo ">>> Configuring ZRAM"
echo ">> available compression algorithms:"
    if ! lsmod | grep -q zram; then
        sudo modprobe zram num_devices=1
    fi
# Getting available algorithms

    AVAILABLE_ALGOS=$(cat /sys/block/zram0/comp_algorithm 2>/dev/null || echo "lzo lzo-rle lz4 zstd")
        # Convert space-separated string to array
    read -r -a ALGO_ARRAY <<< "$AVAILABLE_ALGOS"

    CLEAN_ALGOS=()
    for alg in "${ALGO_ARRAY[@]}"; do
        CLEAN_ALGOS+=("${alg//[\[\]]/}")
    done

    for i in "${!CLEAN_ALGOS[@]}"; do
        echo "   [$i] ${CLEAN_ALGOS[$i]}"
    done

    echo ""
    read -p ">> Select algorithm index (Default: zstd): " ALGO_INDEX

    # Determine selected algorithm
    if [[ -z "$ALGO_INDEX" ]]; then
            SELECTED_ALGO="zstd"
        else
            # Validate input is a number and within range
            if [[ "$ALGO_INDEX" =~ ^[0-9]+$ ]] && [ "$ALGO_INDEX" -lt "${#CLEAN_ALGOS[@]}" ]; then
                SELECTED_ALGO="${CLEAN_ALGOS[$ALGO_INDEX]}"
            else
                echo "Invalid selection, defaulting to zstd"
                SELECTED_ALGO="zstd"
            fi
    fi
    
    echo ">> Selected: $SELECTED_ALGO"

    pacman_install zram-generator
    echo ""
    echo ">> Enter ZRAM size."
    echo "   Examples: 'ram' (full size), 'ram / 2' (half), '4096' (4GB fixed), 'min(ram, 4096)'"
    read -p ">> Size (Default: ram): " USER_SIZE

    if [[ -z "$USER_SIZE" ]]; then
        ZRAM_SIZE="ram"
    else
        ZRAM_SIZE="$USER_SIZE"
    fi
    echo ">> Selected Size: $ZRAM_SIZE"

    echo ">>> Writing /etc/systemd/zram-generator.conf..."
    sudo bash -c "cat > /etc/systemd/zram-generator.conf <<EOF
        [zram0]
        zram-size = $ZRAM_SIZE
        compression-algorithm = $SELECTED_ALGO
        EOF"

    sudo systemctl daemon-reload
    sudo systemctl restart systemd-zram-setup@zram0.service
    echo ">>> If ZRAM doesn't show up right now , don't worry , try a reboot :)"
    echo ">>> ZRAM Status:"
    zramctl


    echo ">>> Build asusctl locally from source ? [Y/n]"
    echo ">>> Installing Asusctl , building from source "
    yay_install asusctl 

PKGS=( "btop" "fastfetch" "fortune-mod" "cowsay" "lolcat" "bat" "yazi" "nvim" "fzf" "ncdu" "dust" "helix" )

      echo ">>> Installing additional packages: ${PKGS[*]}"
      pacman_install "${PKGS[@]}"

      read -rp "Install LazyVim config? [y/N]: " ans
      ans=${ans:-N}

      if [[ $ans =~ ^[Yy]$ ]]; then
        git clone https://github.com/LazyVim/starter ~/.config/nvim
      else
        echo "Warning : Neovim has been installed without lazyvim config "
      fi



DEVTOOLS=("rust" "python" "node" "git" "llvm" "clang" "lazygit" "ripgrep")

echo ">>> Installling Dev tools "
pacman_install "${DEVTOOLS[@]}"
yay_install visual-studio-code-bin  

echo ">>> Setup complete! Please restart your shell."
