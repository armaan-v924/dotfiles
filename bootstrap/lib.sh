#!/usr/bin/env bash
set -euo pipefail

source "$DOTFILES/shell/colors.sh"
source "$DOTFILES/shell/log.sh"

OS=""
case "$(uname)" in
	Darwin) OS="darwin" ;;
	Linux)  OS="linux" ;;
	*)
	  echo "Unsupported OS"
	  exit 1
	  ;;
esac

export OS

export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
