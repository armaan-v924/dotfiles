#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
PROVIDERS_DIR="$DOTFILES/bootstrap/providers"

source "$DOTFILES/bootstrap/lib.sh"
source "$PROVIDERS_DIR/common.sh"
source "$PROVIDERS_DIR/brew.sh"
source "$PROVIDERS_DIR/apt.sh"
source "$PROVIDERS_DIR/custom.sh"

install_packages_darwin() {
  brew::install
}

install_packages_linux() {
  apt::install
  brew::install
}

case "$OS" in
  darwin) install_packages_darwin ;;
  linux)  install_packages_linux ;;
  *)
    log::error "Unsupported OS for package install: $OS"
    exit 1
    ;;
esac

custom::run_scripts
