#!/usr/bin/env sh
# Prints a Nerd Font OS icon for tmux status bar

set -eu

uname_s="$(uname -s 2>/dev/null || echo unknown)"

case "$uname_s" in
  Darwin)
    printf ""
    ;;
  Linux)
    printf ""
    ;;
  *)
    printf ""
    ;;
esac
