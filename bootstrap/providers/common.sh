# shellcheck shell=bash
# Common helpers shared by package providers.

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

manifest_lines() {
  # Print normalized package lines from a manifest:
  # - strips comments (# ...)
  # - trims whitespace
  # - drops blanks
  local file="$1"
  [[ -f "$file" ]] || return 0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"                                 # strip comments
    line="${line#"${line%%[![:space:]]*}"}"            # trim leading
    line="${line%"${line##*[![:space:]]}"}"            # trim trailing
    [[ -n "$line" ]] || continue
    printf '%s\n' "$line"
  done < "$file"
}

collect_manifests() {
  # Usage: collect_manifests <manifest> [variant ...]
  # Example: collect_manifests packages common "$OS"
  # Outputs absolute manifest paths for merging:
  # base manifests first, then overlay manifests.
  # Both sets are merged and deduplicated by read_manifest_to_array.
  local manifest="$1"
  shift
  local variants=("$@")

  if [[ "${#variants[@]}" -eq 0 ]]; then
    variants=("")
  fi

  local base_dir="$DOTFILES/manifests"
  local overlay_dir="${DOTFILES_OVERLAY_DIR:-}"
  local dirs=("$base_dir")

  if [[ -n "$overlay_dir" ]]; then
    dirs+=("$overlay_dir/manifests")
  fi

  local dir variant path
  for dir in "${dirs[@]}"; do
    for variant in "${variants[@]}"; do
      path="$dir/$manifest"
      if [[ -n "$variant" ]]; then
        path="$path.$variant"
      fi
      [[ -f "$path" ]] && printf '%s\n' "$path"
    done
  done
}

read_manifest_to_array() {
  # Usage: read_manifest_to_array <array_name> <manifest> [variant ...]
  # Populates array_name with sorted unique package entries.
  # Merges base and overlay manifests, deduplicating package names.
  local __target="$1"
  shift
  local manifest="$1"
  shift
  local files=()

  while IFS= read -r mf; do
    files+=("$mf")
  done < <(collect_manifests "$manifest" "$@")

  eval "$__target=()"

  if [[ "${#files[@]}" -eq 0 ]]; then
    return 0
  fi

  local packages=()
  while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    [[ -n "$pkg" ]] && packages+=("$pkg")
  done < <(
    for mf in "${files[@]}"; do
      manifest_lines "$mf"
    done | sort -u
  )

  local pkg
  for pkg in "${packages[@]}"; do
    eval "$__target+=(\"\${pkg}\")"
  done
}
