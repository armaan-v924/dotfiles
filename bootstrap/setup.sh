#!/usr/bin/env bash
set -euo pipefail

source "$DOTFILES/bootstrap/lib.sh"

run_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0

  # Run scripts in lexical order for determinism
  local s
  for s in "$dir"/*.sh; do
    [[ -f "$s" ]] || continue
    [[ -x "$s" ]] || chmod +x "$s" 2>/dev/null || true
    log::info "Running setup: $s"
    "$s"
  done
}

# Always run core setup scripts
run_dir "$DOTFILES/setup"

# Then overlay setup scripts (if overlay selected and present)
if [[ -n "${DOTFILES_OVERLAY_DIR:-}" ]]; then
  run_dir "$DOTFILES_OVERLAY_DIR/setup"
fi