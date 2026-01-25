# shellcheck shell=bash

set -euo pipefail

brew::_ensure() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  log::info "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

brew::_load_env() {
  local candidate=""

  if [[ -x /opt/homebrew/bin/brew ]]; then
    candidate="/opt/homebrew/bin/brew"
  elif [[ -x /usr/local/bin/brew ]]; then
    candidate="/usr/local/bin/brew"
  elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    candidate="/home/linuxbrew/.linuxbrew/bin/brew"
  elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
    candidate="$HOME/.linuxbrew/bin/brew"
  fi

  [[ -n "$candidate" ]] || return 0
  eval "$("$candidate" shellenv)"
}

brew::_install_formulae() {
  local formulae=()
  read_manifest_to_array formulae packages common "$OS"

  if (( ${#formulae[@]} == 0 )); then
    log::info "No brew formulae requested."
    return 0
  fi

  log::info "Installing brew formulae: ${formulae[*]}"
  brew install "${formulae[@]}"
}

brew::_install_casks() {
  [[ "$OS" == "darwin" ]] || return 0

  local casks=()
  read_manifest_to_array casks casks darwin

  if (( ${#casks[@]} == 0 )); then
    log::info "No brew casks requested."
    return 0
  fi

  log::info "Installing brew casks: ${casks[*]}"
  brew install --cask --adopt "${casks[@]}"
}

brew::install() {
  brew::_ensure
  brew::_load_env

  log::info "Updating Homebrew..."
  brew update

  brew::_install_formulae
  brew::_install_casks

  brew cleanup || true
}
