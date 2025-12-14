# zsh Layout

Zsh startup is intentionally partitioned so each phase stays small and predictable.

## Files & Symlinks

| File | Linked to | Purpose |
| --- | --- | --- |
| `environment.sh` | `~/.zshenv` | Runs for every zsh invocation. Defines `$DOTFILES`, PATH seeds, and other universal env vars. Must stay non-interactive and fast. |
| `profile.sh` | `~/.zprofile` | Login shells only. Extends PATH (e.g., adds `$HOME/.cargo/bin`) and exports OS/runtime variables. |
| `run_commands.sh` | `~/.zshrc` | Interactive shells. Sets up completions, fzf-tab, aliases, zoxide overrides, syntax highlighting, etc. |
| `login.sh` | `~/.zlogin` | Runs once per login shell. Auto-attaches to tmux unless disabled via `DOTFILES_DISABLE_AUTO_TMUX`. |
| `plugins/` | Helper scripts (e.g., vendored fzf-tab) loaded by `run_commands.sh` when present. |

Symlinks are managed by `bootstrap/link.sh`.

## Design Notes

* Leader key for shell shortcuts is space (mirrors Neovim).
* fzf-tab provides completion UI with tmux-aligned theming + previews.
* `cd` is wrapped to fall back to zoxide when the target directory doesn’t exist.
* Nerd Font icons are used sparingly (prompts, fzf markers).
* tmux is the “base UI”; starship prompt stays minimal.

To customize behavior:

1. Edit the appropriate file (e.g., add aliases in `run_commands.sh`).
2. Keep `.zshenv`/`environment.sh` tiny—no conditionals, no subshells.
3. Use overlays for work-specific additions (overlay `shell/` mirrors this layout).
