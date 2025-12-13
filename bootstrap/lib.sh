#!/usr/bin/env bash
set -euo pipefail

source "$DOTFILES/shell/colors.sh"
source "$DOTFILES/shell/log.sh"

OS=""
case "$(uname)" in
  Darwin) OS="darwin" ;;
  Linux)  OS="linux" ;;
  *)
    log::error "Unsupported OS: $(uname)"
    exit 1
    ;;
esac
export OS
