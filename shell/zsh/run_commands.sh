if [[ -z "${DOTFILES_COMPINIT:-}" ]]; then
  autoload -Uz compinit && compinit -u
  DOTFILES_COMPINIT=1
fi

if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="--layout=reverse --info=inline --border=rounded --prompt=' ' --pointer='' --marker='' --color=fg:#d5d7de,bg:-1,hl:#8aa2d3 --color=fg+:#f8f8f2,bg+:#1b1d23,hl+:#8aa2d3 --color=pointer:#8aa2d3,marker:#8aa2d3,header:#8aa2d3,prompt:#8aa2d3,spinner:#8aa2d3,border:#2b2d37,separator:#2b2d37,scrollbar:#2b2d37,gutter:#1b1d23"

  _dotfiles_fzf_preview=""
  if command -v bat >/dev/null 2>&1; then
    _dotfiles_fzf_preview="bat --style=plain --color=always --line-range=:200 \$realpath 2>/dev/null || cat \$realpath 2>/dev/null"
  else
    _dotfiles_fzf_preview="sed -n '1,200p' \$realpath 2>/dev/null"
  fi

  for _fzf_tab_dir in \
    "$DOTFILES/shell/zsh/plugins/fzf-tab" \
    "/opt/homebrew/share/fzf-tab" \
    "/opt/homebrew/opt/fzf-tab/share/fzf-tab"
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
  zstyle ':fzf-tab:complete:*:*' fzf-preview "if [[ -d \$realpath ]]; then eza -1 --color=always \$realpath 2>/dev/null; else ${_dotfiles_fzf_preview}; fi"
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

if [[ -f "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
if [[ -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
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

eval "$(starship init zsh)"
