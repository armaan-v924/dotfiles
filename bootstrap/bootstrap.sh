#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

source "$DOTFILES/shell/colors.sh"
source "$DOTFILES/bootstrap/lib.sh"

echo "------------------- BOOTSTRAP -------------------"
echo "Bootstrap starting for OS: $BOLD$YELLOW$OS$RESET"
