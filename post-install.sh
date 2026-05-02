#!/bin/bash

# post-install.sh - Configuration deployment for fresh install
# This script handles moving dotfiles to their respective locations in ~/.config

# Abort on error
set -e

# Get the directory where this script is located
REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create Screenshots directory
echo ">>> Creating Screenshots directory in ~/Pictures/Screenshots"
mkdir -p "$HOME/Pictures/Screenshots"

# Function to deploy configs
deploy_config() {
  local src="$REPO_ROOT/$1"
  local dest="$HOME/.config/$2"

  if [ -d "$src" ]; then
    echo ">>> Deploying $src to $dest"
    mkdir -p "$dest"
    # Using cp -r to avoid moving files out of the repository
    cp -rv "$src/"* "$dest/"
  else
    echo ">>> Warning: Source directory $src does not exist. Skipping."
  fi
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
if [ -d "$REPO_ROOT/wallpapers" ]; then
    cp -rv "$REPO_ROOT/wallpapers/"* "$HOME/Pictures/Wallpapers/"
else
    echo ">>> Warning: wallpapers directory not found."
fi

echo ">>> Dotfiles deployment complete!"
