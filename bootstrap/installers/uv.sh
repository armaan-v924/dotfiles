#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
source "$DOTFILES/bootstrap/lib.sh"

ensure_uv() {
    if command -v uv >/dev/null 2>&1; then
        log::debug "uv already present; skipping uv installer."
        return 0
    fi

    log::info "Installing uv (from https://astral.sh/uv)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    log::info "uv installation complete."
}

ensure_uv