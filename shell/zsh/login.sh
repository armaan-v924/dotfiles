#!/usr/bin/env zsh

# Auto-start tmux for login shells only (requested behavior).
# If the user is already inside tmux or has opted out, do nothing.

if [[ -n "${DOTFILES_DISABLE_AUTO_TMUX:-}" ]]; then
  return
fi

# Ensure we only interfere with interactive login shells.
case $- in
  *i*) ;;
  *) return ;;
esac

if command -v tmux >/dev/null 2>&1 && [[ -z "${TMUX:-}" ]]; then
  session="${DOTFILES_TMUX_SESSION:-main}"
  # Attach to existing session if available, otherwise create it.
  exec tmux new-session -A -s "$session"
fi
