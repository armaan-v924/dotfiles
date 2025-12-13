#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
source "$DOTFILES/bootstrap/lib.sh"

require_git() {
  if ! command -v git >/dev/null 2>&1; then
    log::error "git not found; run package installation first"
    exit 1
  fi
}

prompt() {
  local msg="$1" default="${2:-}" value=""
  if [[ -n "$default" ]]; then
    read -rp "$msg [$default]: " value
    [[ -z "$value" ]] && value="$default"
  else
    read -rp "$msg: " value
  fi
  printf '%s' "$value"
}

yesno() {
  local msg="$1" default="${2:-N}" value
  value="$(prompt "$msg (y/N)" "$default")"
  [[ "$value" =~ ^[Yy]$ ]]
}

write_kv() {
  local file="$1" key="$2" val="$3"
  git config --file "$file" "$key" "$val"
}

main() {
  require_git

  local machine_file="$HOME/.gitconfig-machine"
  local personal_scope_file="$HOME/.gitconfig-personal-scope"
  local personal_scope_dir="$HOME/personal-projects/"

  log::info "Starting Git setup"
  log::info "Overlay: ${DOTFILES_OVERLAY:-none}"

  # Detect overlay gitconfig (if present)
  local overlay_gitconfig=""
  if [[ -n "${DOTFILES_OVERLAY_DIR:-}" ]]; then
    if [[ -f "$DOTFILES_OVERLAY_DIR/git/gitconfig" ]]; then
      overlay_gitconfig="$DOTFILES_OVERLAY_DIR/git/gitconfig"
      log::info "Detected overlay gitconfig: $overlay_gitconfig"
    else
      log::debug "No overlay gitconfig found"
    fi
  fi

  # Defaults (overlay can provide)
  local name_default email_default
  name_default="${GIT_NAME_DEFAULT:-$(git config --global --get user.name 2>/dev/null || true)}"
  email_default="${GIT_EMAIL_DEFAULT:-$(git config --global --get user.email 2>/dev/null || true)}"

  local name email
  name="$(prompt "Machine-wide Git user.name (applies everywhere)" "$name_default")"
  email="$(prompt "Machine-wide Git user.email (applies everywhere)" "$email_default")"

  if [[ -z "$name" || -z "$email" ]]; then
    log::error "user.name and user.email must not be empty"
    exit 1
  fi

  log::info "Writing machine-wide git config: $machine_file"
  : > "$machine_file"

  write_kv "$machine_file" "user.name" "$name"
  write_kv "$machine_file" "user.email" "$email"
  write_kv "$machine_file" "init.defaultBranch" "main"
  write_kv "$machine_file" "fetch.prune" "true"
  write_kv "$machine_file" "rerere.enabled" "true"

  if [[ -n "$overlay_gitconfig" ]]; then
    write_kv "$machine_file" "include.path" "$overlay_gitconfig"
    log::info "Overlay gitconfig included everywhere"
  fi

  # Optional scoped personal identity
  if yesno "Configure scoped personal identity under $personal_scope_dir ?" "Y"; then
    mkdir -p "$personal_scope_dir"

    local p_name_default p_email_default
    p_name_default="${PERSONAL_GIT_NAME_DEFAULT:-$name}"
    p_email_default="${PERSONAL_GIT_EMAIL_DEFAULT:-}"

    local p_name p_email
    p_name="$(prompt "Scoped personal user.name" "$p_name_default")"
    p_email="$(prompt "Scoped personal user.email" "$p_email_default")"

    if [[ -z "$p_name" || -z "$p_email" ]]; then
      log::error "Scoped personal name/email must not be empty"
      exit 1
    fi

    log::info "Writing scoped personal config: $personal_scope_file"
    : > "$personal_scope_file"
    write_kv "$personal_scope_file" "user.name" "$p_name"
    write_kv "$personal_scope_file" "user.email" "$p_email"
  else
    # Ensure file exists so includeIf never errors
    : > "$personal_scope_file"
    log::debug "Scoped personal identity skipped"
  fi

  log::info "Git setup complete"
  log::info "Machine-wide config: $machine_file"
  log::info "Personal scoped config: $personal_scope_file"
}

main "$@"
