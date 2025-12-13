#!/usr/bin/env bash
set -euo pipefail

source "$DOTFILES/bootstrap/lib.sh"

read_manifest() {
	# strips comments + blank lines
	sed -e "s/#.$//" -e '/^[[:space:]]*$/d' "$1"
}

install_brew_if_needed() {
	if command -v brew >/dev/null 2>&1; then
		return
	fi

	log::info "Homebrew not found. Installing..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

load_brew_env() {
	if [[ "$OS" == "darwin" ]]; then
		if [[ -x /opt/homebrew/bin/brew ]]; then
			eval "$(/opt/homebrew/bin/brew shellenv)"
		elif [[ -x /usr/local/bin/brew ]]; then
			eval "$(/usr/local/bin/brew shellenv)"
		fi
	fi
}

brew_install_list() {
  local kind="$1"   # "formula" or "cask"
  shift
  local items=("$@")
  (( ${#items[@]} == 0 )) && return 0

  if [[ "$kind" == "cask" ]]; then
    log::info "Installing casks: ${items[*]}"
    brew install --cask "${items[@]}"
  else
    log::info "Installing formulae: ${items[*]}"
    brew install "${items[@]}"
  fi
}

install_packages_darwin() {
  install_brew_if_needed
  load_brew_env

  log::info "Updating Homebrew..."
  brew update

  formulae=()
  casks=()

  # Read common + darwin formulae
  while IFS= read -r pkg; do
    formulae+=("$pkg")
  done < <(
    { read_manifest "$DOTFILES/manifests/packages.common"
      read_manifest "$DOTFILES/manifests/packages.darwin"; }
  )

  # Read casks
  while IFS= read -r cask; do
    casks+=("$cask")
  done < <(
    read_manifest "$DOTFILES/manifests/casks.darwin"
  )

  if [ "${#formulae[@]}" -gt 0 ]; then
    log::info "Installing formulae: ${formulae[*]}"
    brew install "${formulae[@]}"
  fi

  if [ "${#casks[@]}" -gt 0 ]; then
    log::info "Installing casks: ${casks[*]}"
    brew install --cask "${casks[@]}"
  fi

  brew cleanup || true
}


install_packages_linux() {
	log::error "Linux install not implemented yet."
	exit 1
}

case "$OS" in
	darwin) install_packages_darwin ;;
	linux)  install_packages_linux ;;
esac
