# Dotfiles

A comprehensive dotfiles setup for a modern development environment featuring Neovim, Fish shell, and Tmux with plugin management and LSP support.

## Features

- **Neovim**: Fully configured with LSP, autocompletion, Git integration, and modern plugins (managed by lazy.nvim)
- **Fish Shell**: Lightweight `simple.fish` prompt, cross-machine history sync, aliases, and productivity functions
- **Tmux**: Custom keybindings, mouse support, and a modular status bar with toggleable gadgets
- **Cross-platform**: Supports macOS, Linux (Arch, Debian/Ubuntu, Alpine, Fedora/RHEL, Gentoo), and FreeBSD
- **Config Sets**: Pick and choose which groups of config get deployed via the interactive checklist a bare `make` opens
- **Automated Setup**: One-command installation via Makefile

## Quick Install

```bash
make
```

This opens an interactive checklist of the available config sets, then runs
the full install using your selection. The setup automatically detects your
operating system and installs all necessary packages and configurations.

To install just the `basic` set without being asked anything — the right
choice for an unattended install, and what CI runs:

```bash
make basic
```

To re-sync just the config file symlinks (without reinstalling packages or plugins):

```bash
make refresh
```

To re-run the full install using the sets you already picked, without the
checklist:

```bash
make full-install
```

## Repository Layout

```
config/
  sets/
    basic/                        # The default config set (today's dotfiles)
      description                 # One-line blurb shown by `make picky`
      manifest                    # Declares what gets deployed and where
      vim/init.lua                # Neovim configuration
      fish/config.fish            # Fish entrypoint (greeting + $EDITOR)
      fish/aliases.fish           # Shell aliases (deployed to conf.d/)
      fish/functions.fish         # Shell functions (deployed to conf.d/)
      fish/envvars.fish           # Environment variables (copied, per-machine)
      tmux/tmux.conf              # Tmux configuration
      tmux/scripts/status.sh      # Modular status bar renderer
      tmux/scripts/status.conf    # Status gadget list (copied, per-machine)
      tmux/scripts/bluetooth-menu.sh  # Bluetooth popup menu
    git/                           # Git config, aliases, global gitignore, Delta
      description
      manifest
      gitconfig                    # Linked to ~/.config/git/config
      gitignore                    # Linked to ~/.config/git/ignore
      identity                     # Copied to ~/.config/git/identity, per-machine
      apply.sh
    gentoo/                        # The gentoo-kernel-upgrade helper
      description
      manifest
      os                           # "Linux" — hidden from `make picky` elsewhere
      apply.sh
    gnome/                         # GNOME settings (`gsettings`)
      description
      manifest
      os                           # "Linux" — hidden from `make picky` elsewhere
      apply.sh
    kde/                           # KDE Plasma settings (`kwriteconfig5`/`6`)
      description
      manifest
      os                           # "Linux" — hidden from `make picky` elsewhere
      apply.sh
    macos/                         # macOS system settings (`defaults write`)
      description
      manifest
      os                           # "Darwin" — hidden from `make picky` elsewhere
      apply.sh
    xfce/                          # XFCE settings (`xfconf-query`), panel layout, Kitty
      description
      manifest
      os                           # "Linux" — hidden from `make picky` elsewhere
      apply.sh
    # further sets live alongside these, following the same layout
install-scripts/            # Numbered setup scripts run by the Makefile
  lib/sets.sh                # Shared helpers for discovering/enabling sets
  pick-sets.sh               # the dialog checklist; takes set names to skip it
scripts/                    # Misc helper scripts (e.g. Gentoo kernel upgrade)
tests/                      # Dockerfiles used by CI to test installs per distro
```

## Config Sets & `make picky`

Config files are grouped into **sets** under `config/sets/<name>/`:

- **`basic`** — everything this repo has always deployed (Neovim, Fish, Tmux)
- **`git`** — aliases (`st`/`co`/`br`/`ci`/`last`/`unstage`/`amend`), sane
  defaults (autoprune on fetch, `autoSetupRemote` on push, rerere, `diff3`
  conflict markers), a global gitignore, and a per-machine identity file
  (`~/.config/git/identity`, copied once so different machines can carry
  different `user.name`/`user.email`). It also installs **Delta** and wires
  it in as the diff/log pager, with line numbers on and higher-contrast
  colors than its low-contrast-blue defaults — written to a separate,
  untracked `~/.config/git/local` file rather than `git config --global`,
  since with no `~/.gitconfig` yet that resolves to the tracked
  `~/.config/git/config` symlink. lazygit (installed unconditionally by
  `basic`) gets pointed at Delta too, via a `~/.config/lazygit/config.yml`
  deployed the same copy-once way as the identity file
- **`kde`** — sets the KDE Plasma keyboard repeat rate to 50/s with a 250ms
  delay (via `kwriteconfig5`/`6` on `kcminputrc`)
- **`macos`** — the macOS system settings that differ from stock, applied via
  `defaults write`: fastest keyboard repeat rate with the shortest delay, all
  automatic text substitution off, text replacements, the input-source and
  Quick Note hotkeys disabled, dark mode, a faster trackpad, seconds in the
  menu bar clock, no Dock recents, the built-in drag-to-edge window tiling
  off (Rectangle handles that), Finder in list view opening on `~` with a
  status bar, screenshots to the clipboard, personalised ads off, and — if
  passwordless `sudo` is available — a display that never sleeps. It also
  installs **Rectangle** and **Maccy** via Homebrew Cask and applies their
  shortcuts (Cmd+Shift+arrows for window halves, Cmd+Shift+V for clipboard
  history)
- **`xfce`** — the XFCE settings that differ from stock, applied via
  `xfconf-query`: the same keyboard repeat rate and Caps Lock as Escape as
  `kde`/`gnome`, screen locking and idle display dim/off disabled, device
  automounting disabled, an editable path bar in Thunar and GTK file
  dialogs, a dark theme (whichever of a few common ones is actually
  installed), and the default panel layout collapsed down to a single
  panel docked to the bottom of the screen. It also installs and
  configures **Kitty** as the default terminal

Each set is independent and additive — enabling `kde` or `macos` doesn't
disturb `basic`. Every set except `basic` and `git` declares an `os` file
restricting it to its platform, so `make picky` only offers `gentoo`,
`gnome`, `kde` and `xfce` on Linux and `macos` on macOS in the first place;
if one somehow ends up enabled on the wrong OS anyway (e.g. a shared
`sets.conf`), it's skipped with a warning at deploy time instead of failing.

An `os` file is only as specific as `uname -s`, so the Linux sets are offered
on *every* Linux. Each one checks for what it actually needs at deploy time —
`gsettings`, `kwriteconfig`, `xfconf-query`, `/etc/gentoo-release` — and
warns and exits 0 if it isn't there, so picking `gentoo` on Debian is
harmless rather than fatal.

A bare `make` (or `make picky`, the same target by name) gives you an
interactive checklist (space to toggle, enter to confirm) of every set found
under `config/sets/`. Confirming saves your selection to
`~/.config/dotfiles/sets.conf` and immediately kicks off the full install
(packages, plugins, config deployment, last touches) using it — the same
steps `make full-install` runs. Cancelling (Esc) leaves your existing
selection untouched and stops there, without installing anything.

`make basic` is the non-interactive equivalent: it enables just the `basic`
set and installs, skipping the checklist entirely (and skipping the `dialog`
dependency the checklist would otherwise pull in). CI uses it, and so should
any unattended install.

The saved selection is remembered by future `make refresh` / `make
full-install` runs too, so you only need to pick once per machine. If you've
never picked, everything defaults to just `basic`, matching this repo's
historical behavior.

### Adding a new set

1. Create `config/sets/<name>/`.
2. Add a `manifest` file listing what to deploy, one entry per line:
   ```
   link       some/file           ~/.config/some/file
   copy       some/per-machine    ~/.config/some/per-machine
   link-glob  scripts/*.sh        ~/.local/bin/
   run        apply.sh
   ```
   - `link` symlinks (so edits at the destination flow back into the repo)
   - `copy` copies only if the destination doesn't already exist (for
     per-machine files you don't want overwritten on re-runs)
   - `link-glob` symlinks every file matching a glob into a destination
     directory
   - `run` executes a script instead of deploying a file — for settings that
     aren't dotfiles, like the KDE/macOS keyboard repeat rate. It should
     exit 0 even when it can't apply anything (wrong OS/DE), so other
     enabled sets still get deployed; see `config/sets/kde/apply.sh` for an
     example
   - Paths are relative to the set's own directory; destinations may use `~`
3. Optionally add a one-line `description` file — shown next to the set's
   name in the `make picky` checklist.
4. Optionally add an `os` file if the set only makes sense on certain
   platforms — one `uname -s` value per line (e.g. `Darwin`, `Linux`). Sets
   with an `os` file are hidden from `make picky` on any other OS; sets
   without one are offered everywhere. See `config/sets/macos/os` /
   `config/sets/kde/os` for examples.

## Config Files Overview

The `basic` set is deployed by default; see [Config Sets & `make picky`](#config-sets--make-picky) above for how to add or select other sets.

### `config/sets/basic/vim/init.lua` - Neovim Configuration
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

### `config/sets/basic/fish/config.fish` - Fish Shell Entrypoint
- **Deployed to**: `~/.config/fish/config.fish` (symlinked)
- **Purpose**: Minimal Fish entrypoint
- **Features**:
  - Silences the welcome greeting
  - Sets `$EDITOR` to `nvim`

### `config/sets/basic/fish/aliases.fish` - Fish Aliases
- **Deployed to**: `~/.config/fish/conf.d/aliases.fish` (symlinked)
- **Purpose**: Command aliases loaded automatically by Fish
- **Features**:
  - OS-specific package manager aliases (`get`, `search`)
  - Tooling aliases: `vim` → nvim, `cat` → bat, `ls` → eza, `lg` → lazygit
  - Kubernetes shortcuts (`k`, `kp`, `kc`)
  - Gentoo and PipeWire volume helpers

### `config/sets/basic/fish/functions.fish` - Fish Functions
- **Deployed to**: `~/.config/fish/conf.d/functions.fish` (symlinked)
- **Purpose**: Custom shell functions
- **Features**:
  - Bash-like `!!` history expansion
  - `cheat` lookup against cht.sh
  - `gitissue` helper to branch off a fresh `master`

### `config/sets/basic/fish/envvars.fish` - Environment Variables
- **Deployed to**: `~/.config/fish/conf.d/envvars.fish` (copied, not symlinked)
- **Purpose**: Per-machine environment variable definitions
- **Note**: Only copied if it doesn't already exist, so local customizations are preserved

### `config/sets/basic/tmux/tmux.conf` - Tmux Configuration
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

### `config/sets/basic/tmux/scripts/` - Tmux Status Scripts
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
- **Arch Linux**: Uses pacman, installs the yay AUR helper, and installs `cronie` (cron daemon) for the hourly pacman sync job set up in `07-last-touches.sh`
- **Debian/Ubuntu**: Uses apt (`go` → `golang`, skips lazygit)
- **Alpine**: Uses apk
- **Fedora/RHEL/CentOS**: Uses dnf (skips curl and lazygit)
- **FreeBSD**: Uses pkg
- **Gentoo**: Uses emerge (`git` → `dev-vcs/git`)

### 2. File Deployment (`02-move-files.sh`)
Deploys each enabled config set (`basic` by default, or whatever was chosen
via `make picky`) by walking its `manifest`:
- Creates any destination directories on the fly
- Symlinks most files into place, so edits to the live config flow straight
  back to the repo
- Copies (rather than symlinks) per-machine files like `envvars.fish` and
  `status.conf`, and only if they don't already exist

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
- On Arch, enables the cron daemon and installs an hourly `sudo pacman -Syy`
  cron job for the current user; if that user isn't root, grants them
  passwordless sudo (`/etc/sudoers.d/99-<user>-nopasswd`) so the unattended
  job can actually run

## Manual Setup

If you prefer manual installation or want to customize the process:

1. **Install packages manually**: Check `install-scripts/01-install-packages.sh` for your OS
2. **Copy config files**:
   ```bash
   # Neovim
   mkdir -p ~/.config/nvim
   ln -sf "$PWD/config/sets/basic/vim/init.lua" ~/.config/nvim/init.lua

   # Fish
   mkdir -p ~/.config/fish/conf.d
   ln -sf "$PWD/config/sets/basic/fish/config.fish" ~/.config/fish/config.fish
   ln -sf "$PWD/config/sets/basic/fish/aliases.fish" ~/.config/fish/conf.d/aliases.fish
   ln -sf "$PWD/config/sets/basic/fish/functions.fish" ~/.config/fish/conf.d/functions.fish
   cp "$PWD/config/sets/basic/fish/envvars.fish" ~/.config/fish/conf.d/

   # Tmux
   ln -sf "$PWD/config/sets/basic/tmux/tmux.conf" ~/.tmux.conf
   mkdir -p ~/.tmux/scripts
   ln -sf "$PWD"/config/sets/basic/tmux/scripts/*.sh ~/.tmux/scripts/
   cp "$PWD/config/sets/basic/tmux/scripts/status.conf" ~/.tmux/scripts/
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
- **Add Fish aliases**: Edit `config/sets/basic/fish/aliases.fish`
- **Add Fish functions**: Edit `config/sets/basic/fish/functions.fish`
- **Modify Neovim plugins**: Edit `config/sets/basic/vim/init.lua`
- **Change Tmux keybindings**: Edit `config/sets/basic/tmux/tmux.conf`
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
  - macOS

- **Docker-based Testing**: Each Linux distribution test runs in a containerized environment using Docker Buildx with QEMU for cross-platform compatibility

- **Native Testing**: macOS has no equivalent official container image, so it runs the full install directly on a hosted `macos-latest` runner instead

- **Build Verification**: The GitHub Action (`pr-test.yml`) verifies that the dotfiles can be successfully built on each supported platform, and that the install actually landed (symlinks in place, fish functions loaded) — not just that the install command exited 0

### Workflow Details

The PR testing workflow:
1. Triggers on pull requests to `master` or `main` branches
2. Uses a matrix strategy to test against multiple Linux distributions, plus a separate macOS job
3. Sets up QEMU and Docker Buildx for multi-platform Linux testing
4. Builds the dotfiles installation in each distribution's container, and runs the full install natively on macOS

This ensures that changes don't break compatibility with any supported operating system before they're merged.

## Contributing

Please don't contribute.
