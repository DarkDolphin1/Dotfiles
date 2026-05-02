#!/bin/bash

# sddm.sh - SDDM theme configuration

# Abort on error
set -e

echo ">>> SDDM theme configuration"

read -rp "Would you like to install the sddm-astronaut-theme? [y/N]: " ans
ans=${ans:-N}

if [[ $ans =~ ^[Yy]$ ]]; then
    echo ">>> Installing sddm-astronaut-theme pack..."
    # The astronaut theme setup script handles its own dependencies and configuration
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
    
    # Note: The astronaut theme script typically sets itself as the default theme in /etc/sddm.conf.d/
    echo ">>> sddm-astronaut-theme installation initiated."
else
    echo ">>> Skipping SDDM theme installation."
fi
