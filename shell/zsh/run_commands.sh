if [[ -z "${DOTFILES_COMPINIT:-}" ]]; then
  autoload -Uz compinit && compinit -u
  DOTFILES_COMPINIT=1
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
