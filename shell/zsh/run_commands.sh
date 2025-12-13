if [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" ]]; then
  tmux setenv -g TMUX_SSH 1 2>/dev/null || true
else
  tmux setenv -g TMUX_SSH 0 2>/dev/null || true
fi

eval "$(starship init zsh)"