export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# Ensure Rust toolchain binaries are on PATH whenever available.
if [[ -d "$HOME/.cargo/bin" ]]; then
  PATH="$HOME/.cargo/bin:$PATH"
fi
