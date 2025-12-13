# shellcheck shell=bash

set -euo pipefail

apt::install() {
  [[ "$OS" == "linux" ]] || return 0

  if ! command -v apt-get >/dev/null 2>&1; then
    log::warn "apt-get not found; skipping apt provider."
    return 0
  fi

  local packages=()
  read_manifest_to_array packages apt linux

  if (( ${#packages[@]} == 0 )); then
    log::info "No apt packages requested."
    return 0
  fi

  log::info "Updating apt package index..."
  sudo apt-get update

  log::info "Installing apt packages: ${packages[*]}"
  sudo apt-get install -y "${packages[@]}"
}
