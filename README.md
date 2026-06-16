# Dotfiles

A comprehensive dotfiles setup for a modern development environment featuring Neovim, Fish shell, and Tmux with plugin management and LSP support.

## Features

- **Neovim**: Fully configured with LSP, autocompletion, Git integration, and modern plugins (managed by lazy.nvim)
- **Fish Shell**: Lightweight `simple.fish` prompt, cross-machine history sync, aliases, and productivity functions
- **Tmux**: Custom keybindings, mouse support, and a modular status bar with toggleable gadgets
- **Cross-platform**: Supports macOS, Linux (Arch, Debian/Ubuntu, Alpine, Fedora/RHEL, Gentoo), and FreeBSD
- **Automated Setup**: One-command installation via Makefile

## Quick Install

```bash
make
```

The setup will automatically detect your operating system and install all necessary packages and configurations.

To re-sync just the config file symlinks (without reinstalling packages or plugins):

```bash
make refresh
```

## Repository Layout

```
config/
  vim/init.lua              # Neovim configuration
  fish/config.fish          # Fish entrypoint (greeting + $EDITOR)
  fish/aliases.fish         # Shell aliases (deployed to conf.d/)
  fish/functions.fish       # Shell functions (deployed to conf.d/)
  fish/envvars.fish         # Environment variables (copied, per-machine)
  tmux/tmux.conf            # Tmux configuration
  tmux/scripts/status.sh    # Modular status bar renderer
  tmux/scripts/status.conf  # Status gadget list (copied, per-machine)
  tmux/scripts/bluetooth-menu.sh  # Bluetooth popup menu
install-scripts/            # Numbered setup scripts run by the Makefile
scripts/                    # Misc helper scripts (e.g. Gentoo kernel upgrade)
tests/                      # Dockerfiles used by CI to test installs per distro
```

## Config Files Overview

### `config/vim/init.lua` - Neovim Configuration
- **Deployed to**: `~/.config/nvim/init.lua` (symlinked)
- **Purpose**: Complete Neovim setup with modern IDE-like features
- **Features**:
  - Plugin management with [lazy.nvim](https://github.com/folke/lazy.nvim) (bootstraps itself on first launch)
  - LSP support via Mason for Bash, Docker, Go, JSON, YAML, Python, and Lua
  - Autocompletion with nvim-cmp
  - File explorer (nvim-tree), fuzzy finding (fzf + Telescope), and diagnostics
  - Git integration with fugitive and gitsigns
  - Syntax highlighting with Treesitter
  - Custom keybindings and the carbonfox colorscheme (nightfox.nvim)

### `config/fish/config.fish` - Fish Shell Entrypoint
- **Deployed to**: `~/.config/fish/config.fish` (symlinked)
- **Purpose**: Minimal Fish entrypoint
- **Features**:
  - Silences the welcome greeting
  - Sets `$EDITOR` to `nvim`

### `config/fish/aliases.fish` - Fish Aliases
- **Deployed to**: `~/.config/fish/conf.d/aliases.fish` (symlinked)
- **Purpose**: Command aliases loaded automatically by Fish
- **Features**:
  - OS-specific package manager aliases (`get`, `search`)
  - Tooling aliases: `vim` → nvim, `cat` → bat, `ls` → eza, `lg` → lazygit
  - Kubernetes shortcuts (`k`, `kp`, `kc`)
  - Gentoo and PipeWire volume helpers

### `config/fish/functions.fish` - Fish Functions
- **Deployed to**: `~/.config/fish/conf.d/functions.fish` (symlinked)
- **Purpose**: Custom shell functions
- **Features**:
  - Bash-like `!!` history expansion
  - `cheat` lookup against cht.sh
  - `gitissue` helper to branch off a fresh `master`

### `config/fish/envvars.fish` - Environment Variables
- **Deployed to**: `~/.config/fish/conf.d/envvars.fish` (copied, not symlinked)
- **Purpose**: Per-machine environment variable definitions
- **Note**: Only copied if it doesn't already exist, so local customizations are preserved

### `config/tmux/tmux.conf` - Tmux Configuration
- **Deployed to**: `~/.tmux.conf` (symlinked)
- **Purpose**: Tmux terminal multiplexer configuration
- **Features**:
  - Custom prefix key (Ctrl+A)
  - Alt-based keybindings for panes, windows, and resizing
  - Mouse support enabled
  - Truecolor passthrough
  - Modular status bar driven by `status.sh`
  - Bluetooth popup menu bound to `prefix + b`
  - Plugin management with TPM (tpm, tmux-better-mouse-mode)

### `config/tmux/scripts/` - Tmux Status Scripts
- **Deployed to**: `~/.tmux/scripts/` (`.sh` symlinked, `status.conf` copied)
- **Purpose**: Render the status bar and power the Bluetooth menu
- **Features**:
  - `status.sh`: renders gadgets (WLAN, Bluetooth, battery, CPU, memory, temperature, disk) cross-platform (macOS + Linux)
  - `status.conf`: lists the enabled gadgets and their order — comment out a line to disable a gadget (copied per-machine so local edits stick)
  - `bluetooth-menu.sh`: interactive Bluetooth device menu

## Installation Process

The Makefile's `full-install` target runs 7 sequential scripts for a complete setup:

### 1. Package Installation (`01-install-packages.sh`)
Installs essential packages based on your OS:
- **Common packages**: tmux, neovim, git, fish, curl, bat, go, eza, ripgrep, lazygit
- **macOS**: Uses Homebrew (installs it first if missing)
- **Arch Linux**: Uses pacman and installs the yay AUR helper
- **Debian/Ubuntu**: Uses apt (`go` → `golang`, skips lazygit)
- **Alpine**: Uses apk
- **Fedora/RHEL/CentOS**: Uses dnf (skips curl and lazygit)
- **FreeBSD**: Uses pkg
- **Gentoo**: Uses emerge (`git` → `dev-vcs/git`)

### 2. File Deployment (`02-move-files.sh`)
Symlinks configuration files to their proper locations:
- Creates necessary directories (`~/.config/nvim`, `~/.config/fish`, `~/.tmux/scripts`, etc.)
- Symlinks tracked config files into place, so edits to the live config flow
  straight back to the repo
- Copies (rather than symlinks) `envvars.fish` and `status.conf` so per-machine
  customizations are preserved, and only if they don't already exist

### 3. Fisher Installation (`03-fisher-install.fish`)
Installs Fisher, the Fish shell plugin manager

### 4. Fish Plugins (`04-fish-plugins.fish`)
Installs Fish plugins:
- **simple.fish**: a minimal, fast prompt
- **history-sync.fish**: keeps shell history in sync across sessions/machines

### 5. Tmux Plugins (`05-tmux-plugins.fish`)
Sets up Tmux plugin management:
- Installs TPM (Tmux Plugin Manager) if missing
- Installs/updates configured plugins (tmux-better-mouse-mode)

### 6. Neovim Setup (`06-vim-setup.fish`)
With lazy.nvim no manual bootstrapping is required — plugins and LSP servers
install automatically the first time Neovim launches. This script is kept as a
placeholder for future setup steps.

### 7. Final Configuration (`07-last-touches.sh`)
Completes the setup:
- Adds Fish to `/etc/shells`
- Changes the default shell to Fish
- Creates `~/bin` for personal scripts
- On Gentoo, installs the appropriate kernel-upgrade helper (OpenRC or systemd)

## Manual Setup

If you prefer manual installation or want to customize the process:

1. **Install packages manually**: Check `install-scripts/01-install-packages.sh` for your OS
2. **Copy config files**:
   ```bash
   # Neovim
   mkdir -p ~/.config/nvim
   ln -sf "$PWD/config/vim/init.lua" ~/.config/nvim/init.lua

   # Fish
   mkdir -p ~/.config/fish/conf.d
   ln -sf "$PWD/config/fish/config.fish" ~/.config/fish/config.fish
   ln -sf "$PWD/config/fish/aliases.fish" ~/.config/fish/conf.d/aliases.fish
   ln -sf "$PWD/config/fish/functions.fish" ~/.config/fish/conf.d/functions.fish
   cp "$PWD/config/fish/envvars.fish" ~/.config/fish/conf.d/

   # Tmux
   ln -sf "$PWD/config/tmux/tmux.conf" ~/.tmux.conf
   mkdir -p ~/.tmux/scripts
   ln -sf "$PWD"/config/tmux/scripts/*.sh ~/.tmux/scripts/
   cp "$PWD/config/tmux/scripts/status.conf" ~/.tmux/scripts/
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
- **Add Fish aliases**: Edit `config/fish/aliases.fish`
- **Add Fish functions**: Edit `config/fish/functions.fish`
- **Modify Neovim plugins**: Edit `config/vim/init.lua`
- **Change Tmux keybindings**: Edit `config/tmux/tmux.conf`
- **Toggle status bar gadgets**: Edit `~/.tmux/scripts/status.conf`
- **Add environment variables**: Edit `~/.config/fish/conf.d/envvars.fish`

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
