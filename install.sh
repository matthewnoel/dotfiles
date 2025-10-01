#!/bin/bash

# Dotfiles Installation Script
# Works for both local computers and GitHub Codespaces

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect environment
if [ -n "$CODESPACES" ]; then
    ENVIRONMENT="codespaces"
    print_status "Detected GitHub Codespaces environment"
elif [ -n "$WSL_DISTRO_NAME" ]; then
    ENVIRONMENT="wsl"
    print_status "Detected WSL environment"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    ENVIRONMENT="macos"
    print_status "Detected macOS environment"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ENVIRONMENT="linux"
    print_status "Detected Linux environment"
else
    ENVIRONMENT="unknown"
    print_warning "Unknown environment detected"
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

print_status "Dotfiles directory: $DOTFILES_DIR"

# Ensure zsh is installed
if ! command -v zsh &> /dev/null; then
    print_status "Installing zsh..."
    if [ "$ENVIRONMENT" = "codespaces" ] || [ "$ENVIRONMENT" = "linux" ]; then
        sudo apt-get update && sudo apt-get install -y zsh
    elif [ "$ENVIRONMENT" = "macos" ]; then
        if command -v brew &> /dev/null; then
            brew install zsh
        else
            print_error "Please install Homebrew first, or install zsh manually"
            exit 1
        fi
    fi
    print_success "zsh installed"
else
    print_success "zsh is already installed"
fi

# Set zsh as default shell (only if not already set)
if [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/usr/bin/zsh" ]; then
    print_status "Setting zsh as default shell..."
    if [ "$ENVIRONMENT" = "codespaces" ]; then
        # In Codespaces, we don't change the default shell to avoid issues
        print_warning "Skipping shell change in Codespaces environment"
    else
        sudo chsh -s "$(which zsh)" "$(whoami)"
        print_success "Default shell changed to zsh (restart your terminal to take effect)"
    fi
else
    print_success "zsh is already the default shell"
fi

# Install dotfiles
print_status "Installing dotfiles..."

# Create backup of existing .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    print_status "Backing up existing .zshrc to .zshrc.backup"
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi

# Create backup of existing .zprofile if it exists
if [ -f "$HOME/.zprofile" ]; then
    print_status "Backing up existing .zprofile to .zprofile.backup"
    cp "$HOME/.zprofile" "$HOME/.zprofile.backup"
fi

# Add dotfiles sourcing to .zprofile
DOTFILES_SOURCE_LINE='[[ ! -f ~/dotfiles/generic.zshrc ]] || source ~/dotfiles/generic.zshrc'

# Check if the line already exists in .zprofile
if [ -f "$HOME/.zprofile" ] && grep -Fxq "$DOTFILES_SOURCE_LINE" "$HOME/.zprofile"; then
    print_success "Dotfiles already sourced in .zprofile"
else
    print_status "Adding dotfiles source to .zprofile"
    echo "" >> "$HOME/.zprofile"
    echo "# Dotfiles" >> "$HOME/.zprofile"
    echo "$DOTFILES_SOURCE_LINE" >> "$HOME/.zprofile"
    print_success "Added dotfiles source to .zprofile"
fi

# Install additional tools for Codespaces
if [ "$ENVIRONMENT" = "codespaces" ]; then
    print_status "Installing additional tools for Codespaces..."
    
    # Install useful tools
    sudo apt-get update
    sudo apt-get install -y \
        curl \
        wget \
        unzip \
        tree \
        htop \
        neofetch
    
    print_success "Additional tools installed for Codespaces"
fi

# Create a symlink to dotfiles in home directory for easy access
if [ ! -L "$HOME/dotfiles" ]; then
    print_status "Creating symlink to dotfiles in home directory"
    ln -sf "$DOTFILES_DIR" "$HOME/dotfiles"
    print_success "Created symlink: $HOME/dotfiles -> $DOTFILES_DIR"
fi

print_success "Dotfiles installation completed!"
print_status "Your dotfiles are now available at: $HOME/dotfiles"

if [ "$ENVIRONMENT" = "codespaces" ]; then
    print_warning "Note: In Codespaces, you may need to restart your terminal or run 'source ~/.zprofile' to activate the changes"
else
    print_warning "Note: You may need to restart your terminal or run 'source ~/.zprofile' to activate the changes"
fi

print_status "Available commands:"
print_status "  - status: Show git status and current branch"
print_status "  - notes: Open today.md in VS Code"
print_status "  - start_work <branch>: Start a new feature branch"
print_status "  - push_work <message>: Commit and push current changes"
print_status "  - resolve_work: Clean up current branch and return to main"
print_status "  - resolve_all: Clean up all feature branches"
print_status "  - main: Switch to main branch"
