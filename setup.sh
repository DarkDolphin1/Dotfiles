#!/bin/bash

# setup.sh - Arch Linux Environment Setup
# Abort on error
set -e

echo ">>> Make sure you are running this from your Home Directory without root priv "
cd ~ 

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
        echo ">>> Configuring ZRAM"

        # --- 1. Select Compression Algorithm ---
        echo ">> available compression algorithms:"

        # Check if zram module is loaded to read available algorithms
        if ! lsmod | grep -q zram; then
            sudo modprobe zram num_devices=1
        fi

        # Get available algorithms from system (brackets indicate current, we strip them)
        # Usually prints something like: [lzo] lzo-rle lz4 lz4hc 842 zstd
        AVAILABLE_ALGOS=$(cat /sys/block/zram0/comp_algorithm 2>/dev/null || echo "lzo lzo-rle lz4 zstd")

        # Convert space-separated string to array
        read -r -a ALGO_ARRAY <<< "$AVAILABLE_ALGOS"

        # Remove brackets from the default one if present (e.g. [lzo] -> lzo)
        CLEAN_ALGOS=()
        for alg in "${ALGO_ARRAY[@]}"; do
            CLEAN_ALGOS+=("${alg//[\[\]]/}")
        done

        # Display options
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

        # --- 2. Select ZRAM Size ---
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

        # --- 3. Write Configuration ---
        echo ">>> Writing /etc/systemd/zram-generator.conf..."
        sudo bash -c "cat > /etc/systemd/zram-generator.conf <<EOF
        [zram0]
        zram-size = $ZRAM_SIZE
        compression-algorithm = $SELECTED_ALGO
        EOF"

        # --- 4. Apply Changes ---
        sudo systemctl daemon-reload
        sudo systemctl restart systemd-zram-setup@zram0.service

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

      read -rp "Install LazyVim config? [y/N]: " ans
      ans=${ans:-N}

      if [[ $ans =~ ^[Yy]$ ]]; then
        git clone https://github.com/LazyVim/starter ~/.config/nvim
      else
        echo "Skipping this part"
      fi



DEVTOOLS=("rust" "python" "node" "git" "llvm" "clang" "lazygit")
echo ">>> Installling Dev tools "
sudo pacman -S --needed --noconfirm "${DEVTOOLS[@]}"
yay -S visual-studio-code-bin --noconfirm --needed

echo ">>> Setup complete! Please restart your shell."
