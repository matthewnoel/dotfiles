#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

echo "🚀 Starting dotfiles setup..."

## --- Package Installation ---
# Update and install Zsh and plugins. The '-qq' flag reduces verbose output.
echo "📦 Installing Zsh and plugins..."
sudo apt-get update -qq
sudo apt-get install -y zsh zsh-autosuggestions zsh-syntax-highlighting -qq

## --- Symlink Configuration ---
# This script assumes it's located in the root of your dotfiles repository.
# Source path is relative to the script's location.
# Destination path is in the home directory.
SOURCE_ZSHRC="$(pwd)/generic.zshrc"
DEST_ZSHRC="${HOME}/.zshrc"

# Check if the source file exists before proceeding.
if [ ! -f "$SOURCE_ZSHRC" ]; then
    echo "❌ Error: Source file not found at ${SOURCE_ZSHRC}"
    exit 1
fi

echo "🔗 Creating symlink for .zshrc..."
# Create a symbolic link. The '-f' flag forces overwriting if the
# destination file already exists.
ln -sf "$SOURCE_ZSHRC" "$DEST_ZSHRC"

echo "✅ Dotfiles setup complete! Your .zshrc is now linked."
echo "💡 The new configuration will be active in the next terminal session."
