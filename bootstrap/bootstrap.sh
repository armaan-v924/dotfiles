#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

source "$DOTFILES/shell/colors.sh"
source "$DOTFILES/shell/log.sh"

source "$DOTFILES/bootstrap/lib.sh"

LOG_ICONS=0

log::info "------------------- BOOTSTRAP -------------------"
log::debug "Bootstrap starting for OS: $BOLD$YELLOW$OS$RESET"
