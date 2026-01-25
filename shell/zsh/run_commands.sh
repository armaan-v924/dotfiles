if [[ -z "${DOTFILES_COMPINIT:-}" ]]; then
  autoload -Uz compinit && compinit -u
  DOTFILES_COMPINIT=1
fi

_dotfiles_overlay_helpers="${DOTFILES:-$HOME/.dotfiles}/shell/overlays.sh"
if [[ -f "$_dotfiles_overlay_helpers" ]]; then
  source "$_dotfiles_overlay_helpers"
fi
unset _dotfiles_overlay_helpers

# Source reusable shell utilities (if any)
_dotfiles_utils_dir="$DOTFILES/shell/utils"
_dotfiles_overlay_candidates=($(dotfiles_overlay_dirs 2>/dev/null))
_dotfiles_utils_dirs=("$_dotfiles_utils_dir")
for _dotfiles_overlay_dir in "${_dotfiles_overlay_candidates[@]}"; do
  _dotfiles_overlay_utils="$_dotfiles_overlay_dir/shell/utils"
  if [[ -d "$_dotfiles_overlay_utils" ]]; then
    _dotfiles_utils_dirs+=("$_dotfiles_overlay_utils")
  fi
done

for _dotfiles_utils_dir in "${_dotfiles_utils_dirs[@]}"; do
  if [[ -d "$_dotfiles_utils_dir" ]]; then
    while IFS= read -r -d '' _dotfiles_util; do
      source "$_dotfiles_util"
    done < <(find "$_dotfiles_utils_dir" -type f -name '*.sh' -print0 2>/dev/null | sort -z)
  fi
done
unset _dotfiles_util _dotfiles_utils_dir _dotfiles_utils_dirs _dotfiles_overlay_dir _dotfiles_overlay_utils

# Source shell scripts (non-utils) from base and overlay, allowing overlays to
# extend or override behaviors.
_dotfiles_scripts_dir="$DOTFILES/shell/scripts"
_dotfiles_scripts_dirs=()
if [[ -d "$_dotfiles_scripts_dir" ]]; then
  _dotfiles_scripts_dirs+=("$_dotfiles_scripts_dir")
fi
for _dotfiles_overlay_dir in "${_dotfiles_overlay_candidates[@]}"; do
  _dotfiles_overlay_scripts="$_dotfiles_overlay_dir/shell/scripts"
  if [[ -d "$_dotfiles_overlay_scripts" ]]; then
    _dotfiles_scripts_dirs+=("$_dotfiles_overlay_scripts")
  fi
done

for _dotfiles_scripts_dir in "${_dotfiles_scripts_dirs[@]}"; do
  while IFS= read -r -d '' _dotfiles_script; do
    # Check if this file's directory or any parent contains .no-source marker
    local _check_dir="$(dirname "$_dotfiles_script")"
    local _skip=0
    while [[ "$_check_dir" == "$_dotfiles_scripts_dir"* ]]; do
      if [[ -f "$_check_dir/.no-source" ]]; then
        _skip=1
        break
      fi
      [[ "$_check_dir" == "$_dotfiles_scripts_dir" ]] && break
      _check_dir="$(dirname "$_check_dir")"
    done
    [[ $_skip -eq 1 ]] && continue
    source "$_dotfiles_script"
  done < <(find "$_dotfiles_scripts_dir" -type f -name '*.sh' -print0 2>/dev/null | sort -z)
done
unset _dotfiles_scripts_dir _dotfiles_scripts_dirs _dotfiles_overlay_scripts _dotfiles_script _dotfiles_overlay_candidates _check_dir _skip

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS="--layout=reverse --info=inline --border=rounded --prompt=' ' --pointer='' --marker='' --color=fg:#d5d7de,bg:-1,hl:#8aa2d3 --color=fg+:#f8f8f2,bg+:#1b1d23,hl+:#8aa2d3 --color=pointer:#8aa2d3,marker:#8aa2d3,header:#8aa2d3,prompt:#8aa2d3,spinner:#8aa2d3,border:#2b2d37,separator:#2b2d37,scrollbar:#2b2d37,gutter:#1b1d23"

  _dotfiles_fzf_preview=""
  if command -v bat >/dev/null 2>&1; then
    _dotfiles_fzf_preview="bat --style=plain --color=always --line-range=:200 \$realpath 2>/dev/null || cat \$realpath 2>/dev/null"
  else
    _dotfiles_fzf_preview="sed -n '1,200p' \$realpath 2>/dev/null"
  fi

  for _fzf_tab_dir in \
    "$DOTFILES/shell/zsh/plugins/fzf-tab" \
    "$(brew --prefix)/share/fzf-tab" \
    "$(brew --prefix)/opt/fzf-tab/share/fzf-tab"
  do
    if [[ -f "$_fzf_tab_dir/fzf-tab.plugin.zsh" ]]; then
      fpath=("$_fzf_tab_dir" $fpath)
      source "$_fzf_tab_dir/fzf-tab.plugin.zsh"
      break
    fi
  done
  unset _fzf_tab_dir

  zstyle ':completion:*' menu select
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
  zstyle ':completion:*' group-name ''
  zstyle ':fzf-tab:*' use-fzf-default-opts yes
  zstyle ':fzf-tab:*' fzf-flags --height=15 --layout=reverse-list --border=rounded --info=inline --preview-window=right:55%,border-left
  zstyle ':fzf-tab:*' show-group full
  zstyle ':fzf-tab:*' group-colors $'\x1b[38;2;122;162;247m' $'\x1b[38;2;160;168;205m' $'\x1b[38;2;126;211;165m' $'\x1b[38;2;255;203;107m'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=2 --color=always $realpath 2>/dev/null || ls -a $realpath'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --tree --level=2 --color=always $realpath 2>/dev/null || ls -a $realpath'
  zstyle ':fzf-tab:complete:*:*' fzf-preview "if [[ -d \$realpath ]]; then eza -1 --color=always \$realpath 2>/dev/null; else ${_dotfiles_fzf_preview}; fi"

  zstyle ':completion:*' menu no
  zstyle ':completion:*' menu select setopt completealiases
  unset _dotfiles_fzf_preview
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"

  cd() {
    if [[ $# -eq 0 ]]; then
      builtin cd "$HOME"
      return
    fi

    if [[ -d "$1" || "$1" == "-" ]]; then
      builtin cd "$@"
    else
      z "$@"
    fi
  }
fi

if [[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
if [[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#5c6370"
fi

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -lhF --icons --group-directories-first'
  alias la='eza -lhaF --icons --group-directories-first'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --style=plain --paging=never'
fi

if [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" ]]; then
  tmux setenv -g TMUX_SSH 1 2>/dev/null || true
else
  tmux setenv -g TMUX_SSH 0 2>/dev/null || true
fi

# Source overlay interactive config when an overlay is selected (or when only
# one overlay exists).
_dotfiles_overlay_candidates=($(dotfiles_overlay_dirs 2>/dev/null))
for _dotfiles_overlay_dir in "${_dotfiles_overlay_candidates[@]}"; do
  _dotfiles_overlay_rc="$_dotfiles_overlay_dir/shell/zsh/run_commands.sh"
  if [[ -f "$_dotfiles_overlay_rc" ]]; then
    source "$_dotfiles_overlay_rc"
  fi
done
unset _dotfiles_overlay_candidates _dotfiles_overlay_dir _dotfiles_overlay_rc

e() {
  if [[ -n $TMUX ]]; then
    tmux split-window -h bash -c 'exec "$@"' _ "$EDITOR" "$@"
  else
    exec "$EDITOR" "$@"
  fi
}

eval "$(uv generate-shell-completion zsh)"
eval "$(tix completions zsh)"
eval "$(starship init zsh)"

eval $(thefuck --alias)

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C $(brew --prefix)/Cellar/tfenv/3.0.0/versions/1.6.2/terraform terraform

complete -o nospace -C $(brew --prefix)/bin/terragrunt terragrunt
