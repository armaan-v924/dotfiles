#!/usr/bin/env bash
set -euo pipefail

source "$DOTFILES/shell/log.sh"

timestamp="$(date +"%Y-%m-%d_%H%M%S")"
backup_root="$HOME/.backup/dotfiles_${timestamp}"

mkdir -p "$backup_root"

# --- helpers ---------------------------------------------------------------

ensure_dir() {
  local d="$1"
  if [[ ! -d "$d" ]]; then
    mkdir -p "$d"
    log::info "Created directory: $d"
  else
    log::debug "Directory exists: $d"
  fi
}

backup_path_if_needed() {
  # If target exists and is NOT the correct symlink, back it up.
  local target="$1"
  local rel="${target#"$HOME"/}" # relative to home for nicer backup layout

  if [[ -e "$target" || -L "$target" ]]; then
    local dest_dir="$backup_root/$(dirname "$rel")"
    ensure_dir "$dest_dir"
    mv "$target" "$dest_dir/"
    log::warn "Backed up existing: $target -> $dest_dir/"
  fi
}

link_one() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    log::error "Source missing, cannot link: $src"
    return 1
  fi

  # If dst is a symlink already pointing to src, do nothing.
  if [[ -L "$dst" ]]; then
    local cur
    cur="$(readlink "$dst")" || cur=""
    if [[ "$cur" == "$src" ]]; then
      log::debug "Link OK: $dst -> $src"
      return 0
    fi
  fi

  # If dst exists (file/dir/symlink wrong target), back it up first.
  if [[ -e "$dst" || -L "$dst" ]]; then
    backup_path_if_needed "$dst"
  fi

  ensure_dir "$(dirname "$dst")"
  ln -s "$src" "$dst"
  log::info "Linked: $dst -> $src"
}

link_dir_contents() {
  # Link every file in src_dir into dst_dir (non-recursive)
  local src_dir="$1"
  local dst_dir="$2"

  if [[ ! -d "$src_dir" ]]; then
    log::warn "Directory missing, skipping: $src_dir"
    return 0
  fi

  ensure_dir "$dst_dir"

  local f base
  for f in "$src_dir"/*; do
    [[ -e "$f" ]] || continue
    base="$(basename "$f")"
    link_one "$f" "$dst_dir/$base"
  done
}

# --- XDG dirs --------------------------------------------------------------

ensure_dir "$HOME/.config"
ensure_dir "$HOME/.config/alacritty"
ensure_dir "$HOME/.config/tmux"
ensure_dir "$HOME/.config/tmux/scripts"
ensure_dir "$HOME/.config/ruff"
ensure_dir "$HOME/.config/uv"

# --- alacritty -------------------------------------------------------------

link_one "$DOTFILES/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# --- starship --------------------------------------------------------------

link_one "$DOTFILES/config/starship/starship.toml" "$HOME/.config/starship.toml"

# --- tmux ------------------------------------------------------------------

link_one "$DOTFILES/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
link_dir_contents "$DOTFILES/config/tmux/scripts" "$HOME/.config/tmux/scripts"

# ensure tmux scripts are executable
if [[ -d "$HOME/.config/tmux/scripts" ]]; then
  chmod +x "$HOME/.config/tmux/scripts/"*.sh 2>/dev/null || true
  log::debug "Ensured tmux scripts executable (where present)"
fi

# --- git -------------------------------------------------------------------

link_one "$DOTFILES/config/git/gitconfig" "$HOME/.gitconfig"

# Optional local git config (NOT linked, but respected by gitconfig includes)
# You can create this manually or via overlay; we just ensure backups handle it.

# --- zsh -------------------------------------------------------------------

# Core zsh files in repo should exist at these paths:
link_one "$DOTFILES/shell/zsh/environment.sh"  "$HOME/.zshenv"
link_one "$DOTFILES/shell/zsh/profile.sh"      "$HOME/.zprofile"
link_one "$DOTFILES/shell/zsh/run_commands.sh" "$HOME/.zshrc"
link_one "$DOTFILES/shell/zsh/login.sh"        "$HOME/.zlogin"

log::info "Linking complete. Backups (if any) stored at: $backup_root"
