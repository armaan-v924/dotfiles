#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

source "$DOTFILES/bootstrap/lib.sh"

export LOG_ICONS=0

log::info "------------------- BOOTSTRAP -------------------"
log::debug "Bootstrap starting for OS: $BOLD$YELLOW$OS$RESET"

log::info "Starting package installation."
"$DOTFILES/bootstrap/install-packages.sh"
log::info "Package installation complete."

log::info "Starting linking stage."
"$DOTFILES/bootstrap/link.sh"
log::info "Linking stage complete."

log::info "----------------- END BOOTSTRAP -----------------"

