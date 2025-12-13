#!/usr/bin/env bash
set -euo pipefail

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
