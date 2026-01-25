# Helper utilities for overlay discovery shared by shell startup scripts.
#
# Priority order for overlay selection:
#   1. DOTFILES_OVERLAY_DIR env var (explicit path override)
#   2. .overlay file (persisted bootstrap selection)
#   3. DOTFILES_OVERLAY env var (name-based override)
#   4. Auto-discovery (convenience for single overlay)

dotfiles_overlay_dirs() {
  local -a _dirs=()
  local overlays_root="$DOTFILES/overlays"
  local overlay_file="$DOTFILES/.overlay"

  # 1. Explicit env var wins (for manual override)
  if [[ -n "${DOTFILES_OVERLAY_DIR:-}" && -d "$DOTFILES_OVERLAY_DIR" ]]; then
    _dirs+=("$DOTFILES_OVERLAY_DIR")

  # 2. Read from persisted overlay file (set by bootstrap)
  elif [[ -f "$overlay_file" ]]; then
    local overlay_name
    overlay_name="$(cat "$overlay_file" | tr -d '[:space:]')"
    if [[ -n "$overlay_name" && -d "$overlays_root/$overlay_name" ]]; then
      _dirs+=("$overlays_root/$overlay_name")
    fi

  # 3. Fall back to DOTFILES_OVERLAY env var
  elif [[ -n "${DOTFILES_OVERLAY:-}" && -d "$overlays_root/$DOTFILES_OVERLAY" ]]; then
    _dirs+=("$overlays_root/$DOTFILES_OVERLAY")

  # 4. Finally, auto-discover if exactly one overlay exists
  elif [[ -d "$overlays_root" ]]; then
    while IFS= read -r -d '' _dir; do
      _dirs+=("$_dir")
    done < <(find "$overlays_root" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null | sort -z)

    # Only auto-apply if there is exactly one overlay present.
    if [[ "${#_dirs[@]}" -ne 1 ]]; then
      _dirs=()
    fi
  fi

  printf '%s\n' "${_dirs[@]}"
}
