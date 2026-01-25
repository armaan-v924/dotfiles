#!/usr/bin/env zsh

# Auto-start tmux for login shells only (requested behavior), while still
# allowing overlays to extend login-time behavior.

# Ensure we only interfere with interactive login shells.
case $- in
  *i*) ;;
  *) return ;;
esac

_dotfiles_overlay_helpers="${DOTFILES:-$HOME/.dotfiles}/shell/overlays.sh"
if [[ -f "$_dotfiles_overlay_helpers" ]]; then
  source "$_dotfiles_overlay_helpers"
fi
unset _dotfiles_overlay_helpers

# Allow overlays to run login-time hooks before tmux attach.
_dotfiles_overlay_candidates=($(dotfiles_overlay_dirs 2>/dev/null))
for _dotfiles_overlay_dir in "${_dotfiles_overlay_candidates[@]}"; do
  _dotfiles_overlay_login="$_dotfiles_overlay_dir/shell/zsh/login.sh"
  if [[ -f "$_dotfiles_overlay_login" ]]; then
    source "$_dotfiles_overlay_login"
  fi
done
unset _dotfiles_overlay_candidates _dotfiles_overlay_dir _dotfiles_overlay_login

# If the user is already inside tmux or has opted out, stop here.
if [[ -n "${DOTFILES_DISABLE_AUTO_TMUX:-}" ]]; then
  return
fi

# If the user inside zed, stop here.
if [[ -n "${ZED_TERM:-}" ]]; then
  return
fi

if command -v tmux >/dev/null 2>&1 && [[ -z "${TMUX:-}" ]]; then
  session="${DOTFILES_TMUX_SESSION:-main}"
  # Attach to existing session if available, otherwise create it.
  exec tmux new-session -A -s "$session"
fi
