# zsh Layout

Zsh startup is intentionally partitioned so each phase stays small and predictable.

## Files & Symlinks

| File | Linked to | Purpose |
| --- | --- | --- |
| `environment.sh` | `~/.zshenv` | Runs for every zsh invocation. Defines `$DOTFILES` and sources `*.env` files from base and overlay. Must stay non-interactive and fast. |
| `profile.sh` | `~/.zprofile` | Login shells only. Extends PATH (e.g., `$HOME/.cargo/bin`, `$HOME/.local/bin`, Homebrew) and exports OS/runtime variables. |
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
* `environment.sh` auto-sources `*.env` files under `$DOTFILES` (excluding `.no-source` directories), plus the active overlay (or the only overlay present); other overlays are ignored unless selected.
* Overlays hook into every phase: `profile.sh` and `login.sh` source overlay counterparts, `run_commands.sh` layers overlay utils + `shell/scripts` + interactive tweaks, and `.env` sourcing applies to the active overlay only.

To customize behavior:

1. Edit the appropriate file: aliases in `run_commands.sh`, PATH in `profile.sh`, env vars in `*.env` files.
2. Keep `.zshenv`/`environment.sh` minimal—just `$DOTFILES` definition and env file sourcing.
3. Use overlays for work-specific additions (overlay `shell/` mirrors this layout).
