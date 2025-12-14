# tmux Configuration

tmux is treated as the “base UI”. Login shells auto-attach to tmux (see `shell/zsh/login.sh`), so this configuration aims to be quiet, legible, and fast.

## Layout

```
config/tmux/
├── tmux.conf          # primary config (prefix, status bar, keybinds)
├── scripts/           # helper scripts used by the status bar
└── plugins/           # optional tmux plugins or helper snippets
```

Scripts under `scripts/` are simple executables invoked via `#()` to keep the status line dynamic without cluttering `tmux.conf`.

## Design Notes

* Prefix is `Ctrl-a`.
* Status bar mirrors the Neovim/tmux color palette (subtle greys + blue highlight).
* Left side shows OS icon; right side shows SSH indicator, repo path, kube context, CPU, and RAM.
* Pane borders are intentionally subtle.
* tmux acts as the color/style source of truth; shell prompt stays minimal.

## Customizing

* Add scripts to `scripts/` and reference them via `tmux.conf`.
* Keep configuration XDG-compliant (`~/.config/tmux`).
* If overlays need tweaks, drop an overlay-specific `config/tmux/tmux.conf` and symlink it via overlay bootstrap/linking.
