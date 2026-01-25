_dotfiles_overlay_helpers="${DOTFILES:-$HOME/.dotfiles}/shell/overlays.sh"
if [[ -f "$_dotfiles_overlay_helpers" ]]; then
  source "$_dotfiles_overlay_helpers"
fi
unset _dotfiles_overlay_helpers

# Ensure Rust toolchain binaries are on PATH whenever available.
if [[ -d "$HOME/.cargo/bin" ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# Ensure user-local binaries are on PATH whenever available.
if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Overlay login-time PATH/runtime exports.
_dotfiles_overlay_candidates=($(dotfiles_overlay_dirs 2>/dev/null))
for _dotfiles_overlay_dir in "${_dotfiles_overlay_candidates[@]}"; do
  _dotfiles_overlay_profile="$_dotfiles_overlay_dir/shell/zsh/profile.sh"
  if [[ -f "$_dotfiles_overlay_profile" ]]; then
    source "$_dotfiles_overlay_profile"
  fi
done
unset _dotfiles_overlay_candidates _dotfiles_overlay_dir _dotfiles_overlay_profile

# Homebrew - detect platform-specific location
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi
