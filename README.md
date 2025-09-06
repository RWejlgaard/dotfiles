# Dotfiles

A comprehensive dotfiles setup for a modern development environment featuring Neovim, Fish shell, and Tmux with plugin management and LSP support.

## Features

- **Neovim**: Fully configured with LSP, autocompletion, Git integration, and modern plugins
- **Fish Shell**: Enhanced with tide prompt, aliases, and productivity functions
- **Tmux**: Configured with custom keybindings, mouse support, and status bar
- **Cross-platform**: Supports macOS, Linux (Arch, Debian/Ubuntu, Alpine), and FreeBSD
- **Automated Setup**: One-command installation via Makefile

## Quick Install

```bash
make
```

The setup will automatically detect your operating system and install all necessary packages and configurations.

## Config Files Overview

### `init.lua` - Neovim Configuration
- **Location**: `~/.config/nvim/init.lua`
- **Purpose**: Complete Neovim setup with modern IDE-like features
- **Features**:
  - Plugin management with Packer
  - LSP support for multiple languages (Go, Python, Terraform, Bash, etc.)
  - Autocompletion with nvim-cmp and GitHub Copilot
  - File explorer (Neo-tree), fuzzy finder (fzf), and diagnostics
  - Git integration with fugitive and git-gutter
  - Syntax highlighting with Treesitter
  - Custom keybindings and carbonfox colorscheme

### `config.fish` - Fish Shell Configuration
- **Location**: `~/.config/fish/config.fish`
- **Purpose**: Main Fish shell configuration with aliases and functions
- **Features**:
  - OS-specific package manager aliases (`get`, `search`)
  - Kubernetes shortcuts (`k`, `kp`, `kc`)
  - Vim/Neovim aliases and integrations
  - Custom functions for `cheat` lookup and Git workflows
  - TTY fixes for Asahi Linux
  - Bash-like `!!` history expansion

### `envvars.fish` - Environment Variables
- **Location**: `~/.config/fish/conf.d/envvars.fish`
- **Purpose**: Environment variable definitions for Fish shell
- **Features**:
  - PATH additions for `~/bin` and `~/.local/bin`
  - Template for additional environment variables

### `tmux.conf` - Tmux Configuration
- **Location**: `~/.tmux.conf`
- **Purpose**: Tmux terminal multiplexer configuration
- **Features**:
  - Custom prefix key (Ctrl+A)
  - Alt-based keybindings for panes and windows
  - Mouse support enabled
  - Status bar with CPU/RAM monitoring
  - Plugin management with TPM
  - 256-color terminal support

## Installation Process

The Makefile runs 7 sequential scripts for a complete setup:

### 1. Package Installation (`01-install-packages.sh`)
Installs essential packages based on your OS:
- **Common packages**: tmux, neovim, git, fish, curl, bat, go, npm, ripgrep
- **macOS**: Uses Homebrew
- **Arch Linux**: Uses pacman and installs yay AUR helper
- **Debian/Ubuntu**: Uses apt
- **Alpine**: Uses apk
- **FreeBSD**: Uses pkg

### 2. File Deployment (`02-move-files.sh`)
Copies configuration files to their proper locations:
- Creates necessary directories (`~/.config/nvim`, `~/.config/fish`, etc.)
- Copies config files to home directory
- Preserves existing `envvars.fish` if present

### 3. Fisher Installation (`03-fisher-install.fish`)
Installs Fisher, the Fish shell plugin manager

### 4. Fish Plugins (`04-fish-plugins.fish`)
Installs and configures Fish plugins:
- **Tide**: Modern, customizable prompt with Git integration
- Pre-configured with lean style and 24-hour time format

### 5. Tmux Plugins (`05-tmux-plugins.fish`)
Sets up Tmux plugin management:
- Installs TPM (Tmux Plugin Manager)
- Installs configured plugins (better mouse mode, CPU monitoring)

### 6. Neovim Setup (`06-vim-setup.fish`)
Configures Neovim:
- Bootstraps Packer plugin manager
- Installs all configured plugins
- Sets up LSP servers via Mason

### 7. Final Configuration (`07-last-touches.sh`)
Completes the setup:
- Adds Fish to `/etc/shells`
- Changes default shell to Fish
- Creates `~/bin` directory for personal scripts

## Manual Setup

If you prefer manual installation or want to customize the process:

1. **Install packages manually**: Check `install-scripts/01-install-packages.sh` for your OS
2. **Copy config files**:
   ```bash
   # Neovim
   mkdir -p ~/.config/nvim
   cp init.lua ~/.config/nvim/
   
   # Fish
   mkdir -p ~/.config/fish/conf.d
   cp config.fish ~/.config/fish/
   cp envvars.fish ~/.config/fish/conf.d/
   
   # Tmux
   cp tmux.conf ~/.tmux.conf
   ```
3. **Run individual scripts**: Execute scripts in `install-scripts/` directory in order

## Prerequisites

- Internet connection for downloading packages and plugins
- Sudo access for package installation
- Git for cloning repositories

## Post-Installation

After installation:
1. **Restart your terminal** or run `exec fish` to start using Fish shell
2. **Start tmux** with `tmux` to use the enhanced terminal multiplexer
3. **Open Neovim** with `nvim` to verify plugin installation
4. **Customize**: Edit config files to suit your preferences

## Customization

All configuration files are designed to be easily customizable:
- **Add Fish aliases**: Edit `config.fish`
- **Modify Neovim plugins**: Edit `init.lua`
- **Change Tmux keybindings**: Edit `tmux.conf`
- **Add environment variables**: Edit `envvars.fish`

## Troubleshooting

- **Permission errors**: Ensure you have sudo access
- **Package not found**: Check if your OS is supported in the install scripts
- **Plugin installation fails**: Run individual scripts manually to identify issues
- **Shell not changed**: Log out and back in, or restart your terminal

## CI/CD & Pull Request Checks

This repository includes automated testing via GitHub Actions to ensure the dotfiles installation works correctly across multiple Linux distributions.

### Pull Request Testing

When you submit a pull request, the following automated checks run:

- **Multi-distro Testing**: The installation is tested on:
  - Alpine Linux
  - Arch Linux  
  - Fedora
  - Ubuntu

- **Docker-based Testing**: Each distribution test runs in a containerized environment using Docker Buildx with QEMU for cross-platform compatibility

- **Build Verification**: The GitHub Action (`pr-test.yml`) verifies that the dotfiles can be successfully built on each supported platform

### Workflow Details

The PR testing workflow:
1. Triggers on pull requests to `master` or `main` branches
2. Uses a matrix strategy to test against multiple Linux distributions
3. Sets up QEMU and Docker Buildx for multi-platform testing
4. Builds the dotfiles installation in each distribution's container

This ensures that changes don't break compatibility with any supported operating system before they're merged.

## Contributing

Please don't contribute.
