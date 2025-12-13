# shellcheck shell=bash

set -euo pipefail

custom::run_scripts() {
  local dirs=()
  dirs+=("$DOTFILES/bootstrap/installers")
  if [[ -n "${DOTFILES_OVERLAY_DIR:-}" ]]; then
    dirs+=("$DOTFILES_OVERLAY_DIR/bootstrap/installers")
  fi

  local any=0
  local dir
  for dir in "${dirs[@]}"; do
    [[ -d "$dir" ]] || continue
    while IFS= read -r -d '' script; do
      any=1
      chmod +x "$script" 2>/dev/null || true
      log::info "Running installer: $script"
      "$script"
    done < <(find "$dir" -maxdepth 1 -type f -name "*.sh" -print0 | sort -z)
  done

  if (( ! any )); then
    log::debug "No custom installers found."
  fi
}
