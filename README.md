# Dotfiles

Personal dotfiles configuration that works on local computers and GitHub Codespaces.

## Features

- **Environment Detection**: Automatically detects and configures for different environments (macOS, Linux, WSL, Codespaces)
- **Git Workflow Functions**: Streamlined git commands for feature branch development
- **Useful Aliases**: Common shortcuts for daily development tasks
- **Cross-Platform**: Works seamlessly across different operating systems

## Quick Installation

### GitHub Codespaces

1. Clone this repository in your Codespace:
   ```bash
   git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
   ```

2. Run the installation script:
   ```bash
   bash ~/dotfiles/install.sh
   ```

3. Restart your terminal or run:
   ```bash
   source ~/.zprofile
   ```

### Local Computers

#### Automated Installation (Recommended)
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles

# Run the installation script
bash ~/dotfiles/install.sh
```

#### Manual Installation
```bash
# Add to your .zprofile
echo '\n# Dotfiles\n[[ ! -f ~/dotfiles/generic.zshrc ]] || source ~/dotfiles/generic.zshrc' >> ~/.zprofile
```

## Available Commands

### Git Workflow Functions
- `start_work <branch-name>`: Create and switch to a new feature branch from main
- `push_work "<commit-message>"`: Add, commit, and push current changes
- `resolve_work`: Switch to main, delete current branch, and pull latest
- `resolve_all`: Clean up all feature branches
- `main`: Switch to the main branch

### Aliases
- `status`: Show git status and current branch
- `ls`: Enhanced ls with `-la` flags
- `zshrc`: Open .zshrc in VS Code
- `notes`: Open today.md in VS Code (environment-specific path)

## Environment-Specific Features

### Codespaces
- Automatically detects Codespaces environment
- Uses `/workspaces` directory for notes
- Installs additional development tools
- Optimized for cloud development workflow

### Local Computers
- Uses `~/Desktop` for notes
- Can change default shell to zsh
- Full local development environment setup

## Configuration

The dotfiles automatically detect your environment and configure accordingly:
- **macOS**: Uses Homebrew for package management
- **Linux**: Uses apt-get for package management
- **WSL**: Detects WSL environment
- **Codespaces**: Optimized for cloud development

## Files Structure

```
dotfiles/
├── .devcontainer/
│   └── devcontainer.json    # Codespaces configuration
├── generic.zshrc            # Main configuration file
├── install.sh              # Installation script
└── README.md               # This file
```

## Troubleshooting

### Installation Issues
- Make sure you have `git` and `zsh` installed
- On macOS, install Homebrew if you don't have it
- Run `source ~/.zprofile` after installation

### Codespaces Issues
- The installation runs automatically when creating a Codespace
- If it doesn't work, run `bash ~/dotfiles/install.sh` manually
- Check that the `.devcontainer/devcontainer.json` file is in your repository root

### Git Functions Not Working
- Make sure you're in a git repository
- Ensure you're on the main branch when starting work
- Check that you have no uncommitted changes

## Contributing

1. Fork the repository
2. Create a feature branch: `start_work your-feature-name`
3. Make your changes
4. Commit and push: `push_work "Add your feature"`
5. Create a pull request
6. Clean up: `resolve_work`
