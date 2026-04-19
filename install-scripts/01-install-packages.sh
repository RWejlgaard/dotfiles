#!/bin/bash
set -e # exit on error

exclude() {
    PACKAGES=( $(printf '%s\n' "${PACKAGES[@]}" | grep -vxE "$(IFS='|'; echo "$*")") )
}

replace() {
    PACKAGES=("${PACKAGES[@]/$1/$2}")
}

PACKAGES=(
  "tmux"
  "neovim"
  "git"
  "fish"
  "curl"
  "bat"
  "go"
  "eza"
  "ripgrep"
  "lazygit"
)

# if MacOS install Homebrew
if [ "$(uname)" == "Darwin" ]; then
    if [ ! -x "$(which brew)" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # install packages
    brew install "${PACKAGES[@]}"
fi

# if Arch install
if [ -f /etc/arch-release ]; then
    # install yay
    if [ -z "$(which yay)" ] && [ "$EUID" -ne 0 ]; then
        sudo pacman -S --noconfirm base-devel
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    fi

    # install packages
    sudo pacman -S --noconfirm "${PACKAGES[@]}"
fi

# if debian or ubuntu install
if [ -f /etc/debian_version ]; then
    # replace "go" with "golang" for debian
    replace go golang
    exclude lazygit

    # install packages
    export DEBIAN_FRONTEND=noninteractive
    sudo apt update
    sudo apt install -y "${PACKAGES[@]}"
fi

# if Alpine install
if [ -f /etc/alpine-release ]; then
    # install packages
    sudo apk add "${PACKAGES[@]}"
fi

# if freebsd install
if [ "$(uname)" == "FreeBSD" ]; then
    # install packages
    sudo pkg install -y "${PACKAGES[@]}"
fi

# if RHEL/CentOS/Fedora install
if [ -f /etc/redhat-release ]; then
    exclude curl lazygit

    # install packages
    sudo dnf install -y "${PACKAGES[@]}"
fi

# if Gentoo
if [ -f /etc/gentoo-release ]; then
    replace git dev-vcs/git
    sudo emerge "${PACKAGES[@]}"
fi
