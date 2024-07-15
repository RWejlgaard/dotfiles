#!/bin/bash
set -e # exit on error

PACKAGES=(
  "tmux"
  "neovim"
  "git"
  "fish"
  "curl"
  "bat"
  "go"
  "npm"
  "ripgrep"
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
    sudo pacman -S --noconfirm base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay

    # install packages
    sudo pacman -S --noconfirm "${PACKAGES[@]}"
fi

# if debian or ubuntu install
if [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
    # replace "go" with "golang" for debian
    PACKAGES=("${PACKAGES[@]/go/golang}")

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
