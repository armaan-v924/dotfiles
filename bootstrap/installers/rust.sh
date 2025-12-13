#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
source "$DOTFILES/bootstrap/lib.sh"

install_rustup() {
  if command -v rustup >/dev/null 2>&1; then
    return
  fi

  if [[ "$OS" == "darwin" ]] && command -v brew >/dev/null 2>&1; then
    log::info "Installing rustup-init via Homebrew"
    brew install rustup-init
    rustup-init -y --no-modify-path
  else
    log::info "Installing rustup via official script"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  fi
}

ensure_rust() {
  if command -v cargo >/dev/null 2>&1; then
    log::debug "Cargo already present; skipping rust installer."
    return 0
  fi

  install_rustup

  if command -v rustup >/dev/null 2>&1; then
    rustup default stable >/dev/null
    rustup component add clippy rustfmt >/dev/null || true
    log::ok "Rust toolchain ready."
  else
    log::error "rustup installation failed."
    return 1
  fi
}

ensure_rust
