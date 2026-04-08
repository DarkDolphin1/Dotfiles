#!/bin/bash

# post-install.sh - Configuration deployment for fresh install
# This script handles moving dotfiles to their respective locations in ~/.config

# Create Screenshots directory
echo ">>> Creating Screenshots directory in ~/Pictures/Screenshots"
mkdir -p ~/Pictures/Screenshots

# Function to deploy configs
deploy_config() {
    local src="$1"
    local dest="$HOME/.config/$2"
    
    echo ">>> Deploying $src to $dest"
    mkdir -p "$dest"
    # Using cp -r to avoid moving files out of the repository
    cp -rv "$src/"* "$dest/"
}

# Deploy Hyprland configs
deploy_config "config/hypr" "hypr"

# Deploy Kitty configs
deploy_config "config/kitty" "kitty"

# Deploy Waybar configs
deploy_config "config/waybar" "waybar"

# Deploy Wallpapers
echo ">>> Copying wallpapers to ~/Pictures/Wallpapers"
mkdir -p "$HOME/Pictures/Wallpapers"
cp -rv wallpapers/* "$HOME/Pictures/Wallpapers/"

echo ">>> Dotfiles deployment complete!"
