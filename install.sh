#!/bin/bash

# Define the location where Codespaces clones your dotfiles
DOTFILES_DIR="/workspaces/.codespaces/.persistedshare/dotfiles"

echo "Starting dotfiles setup..."

# 1. Copy the Zsh config file to the home directory
if [ -f "${DOTFILES_DIR}/generic.zshrc" ]; then
    echo "Copying generic.zshrc to ${HOME}/.zshrc"
    cp "${DOTFILES_DIR}/generic.zshrc" "${HOME}/.zshrc"
else
    echo "Error: generic.zshrc not found in the dotfiles directory."
fi

# 2. (Optional) Set Zsh as the default shell
# This command changes the default shell for the current user inside the container.
# It requires the 'zsh' package to be installed, which is common in Codespaces.
if command -v zsh &> /dev/null; then
    echo "Setting Zsh as the default shell..."
    chsh -s "$(command -v zsh)"
else
    echo "Zsh command not found. Skipping default shell change."
fi

echo "Dotfiles setup complete! Please start a new terminal session for changes to take effect."
