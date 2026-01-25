export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
export EDITOR=nvim

_dotfiles_overlay_helpers="$DOTFILES/shell/overlays.sh"
if [[ -f "$_dotfiles_overlay_helpers" ]]; then
  source "$_dotfiles_overlay_helpers"
fi
unset _dotfiles_overlay_helpers

# Source base *.env files (skip overlays + directories with .no-source marker).
while IFS= read -r -d '' env_file; do
  # Check if this file's directory or any parent contains .no-source marker
  local _check_dir="$(dirname "$env_file")"
  local _skip=0
  while [[ "$_check_dir" == "$DOTFILES"* ]]; do
    if [[ -f "$_check_dir/.no-source" ]]; then
      _skip=1
      break
    fi
    [[ "$_check_dir" == "$DOTFILES" ]] && break
    _check_dir="$(dirname "$_check_dir")"
  done
  [[ $_skip -eq 1 ]] && continue
  source "$env_file"
done < <(find "$DOTFILES" -path "$DOTFILES/overlays" -prune -o -type f -name '*.env' -print0 2>/dev/null | sort -z)

# Source overlay *.env files only for the active (or sole) overlay.
_dotfiles_overlay_candidates=($(dotfiles_overlay_dirs 2>/dev/null))
for _dotfiles_overlay_dir in "${_dotfiles_overlay_candidates[@]}"; do
  while IFS= read -r -d '' env_file; do
    # Check if this file's directory or any parent contains .no-source marker
    local _check_dir="$(dirname "$env_file")"
    local _skip=0
    while [[ "$_check_dir" == "$_dotfiles_overlay_dir"* ]]; do
      if [[ -f "$_check_dir/.no-source" ]]; then
        _skip=1
        break
      fi
      [[ "$_check_dir" == "$_dotfiles_overlay_dir" ]] && break
      _check_dir="$(dirname "$_check_dir")"
    done
    [[ $_skip -eq 1 ]] && continue
    source "$env_file"
  done < <(find "$_dotfiles_overlay_dir" -type f -name '*.env' -print0 2>/dev/null | sort -z)
done

unset env_file _dotfiles_overlay_candidates _dotfiles_overlay_dir _check_dir _skip

export ZED_AWS_REGION=us-west-2
export ZED_AWS_PROFILE=vectra-genai-dev
