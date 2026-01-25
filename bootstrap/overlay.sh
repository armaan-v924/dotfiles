#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
source "$DOTFILES/bootstrap/lib.sh"

list_overlays() {
  local overlays_dir="$DOTFILES/overlays"
  [[ -d "$overlays_dir" ]] || return 0

  for d in "$overlays_dir"/*; do
    [[ -d "$d" ]] || continue
    echo "$(basename "$d")"
  done
}

choose_overlay() {
  # 1) explicit env var wins
  if [[ -n "${DOTFILES_OVERLAY:-}" ]]; then
    echo "$DOTFILES_OVERLAY"
    return 0
  fi

  # 2) non-interactive default
  if [[ ! -t 0 ]]; then
    echo "personal"
    return 0
  fi

  # 3) interactive prompt
  local overlays=()
  while IFS= read -r name; do
    overlays+=("$name")
  done < <(list_overlays)

  if [[ "${#overlays[@]}" -eq 0 ]]; then
    log::warn "No overlays found; using 'personal'" >&2
    echo "personal"
    return 0
  fi

  log::info "Available overlays:" >&2
  local i=1
  for name in "${overlays[@]}"; do
    log::info "  [$i] $name" >&2
    i=$((i+1))
  done

  local choice=""
  while true; do
    read -rp "Select overlay (1-${#overlays[@]}) [default: personal]: " choice
    if [[ -z "$choice" ]]; then
      echo "personal"
      return 0
    fi
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice>=1 && choice<=${#overlays[@]} )); then
      echo "${overlays[$((choice-1))]}"
      return 0
    fi
    log::warn "Invalid selection: $choice" >&2
  done
}

apply_overlay_env() {
  local name="$1"
  local overlay_dir="$DOTFILES/overlays/$name"

  # Persist the overlay choice for future shell sessions
  echo "$name" > "$DOTFILES/.overlay"
  log::debug "Persisted overlay selection: $name"

  if [[ ! -d "$overlay_dir" ]]; then
    log::warn "Overlay '$name' not found at $overlay_dir (continuing without overlay env)"
    return 0
  fi

  export DOTFILES_OVERLAY="$name"
  export DOTFILES_OVERLAY_DIR="$overlay_dir"

  # Overlay common env (bash-compatible, loaded by both bootstrap and shell)
  local env_file="$overlay_dir/shell/env.sh"
  if [[ -f "$env_file" ]]; then
    # shellcheck source=/dev/null
    source "$env_file"
    log::info "Applied overlay env: $name"
  else
    log::debug "No overlay env.sh found for $name"
  fi

  # Overlay bootstrap-specific env (bootstrap only, not loaded by shell)
  local bootstrap_env="$overlay_dir/shell/bootstrap/build.env"
  if [[ -f "$bootstrap_env" ]]; then
    # shellcheck source=/dev/null
    source "$bootstrap_env"
    log::info "Applied overlay bootstrap env: $name"
  else
    log::debug "No overlay bootstrap/build.env found for $name"
  fi
}
