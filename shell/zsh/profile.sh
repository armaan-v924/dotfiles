# Ensure Rust toolchain binaries are on PATH whenever available.
if [[ -d "$HOME/.cargo/bin" ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi
