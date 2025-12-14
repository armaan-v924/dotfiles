# Dotfiles

Opinionated, reproducible dotfiles for macOS + Linux with overlay support.

## Quick Start

1. Ensure `git` and network access are available on the target machine.
2. Clone the repo to `~/.dotfiles`.
3. (Optional) Clone an overlay into `~/.dotfiles/overlays/<name>`.
4. Run `~/.dotfiles/bootstrap/bootstrap.sh` and follow the prompts.

See `RECOVERY.md` for the full fresh-machine playbook.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `bootstrap/` | Entry scripts, providers, installers, overlay selection. |
| `config/` | Application configs (`nvim`, `tmux`, etc.). |
| `manifests/` | Package intent (brew/apt/casks). |
| `overlays/` | Ignored, per-environment overrides (same structure as base). |
| `setup/` | Manual, interactive follow-up scripts (git, ssh, etc.). |
| `shell/` | Shared shell assets + zsh partitioning. |

## Operating Principles

* `$HOME` is disposable; `~/.dotfiles` is the source of truth.
* Overlays are independent Git repos and never leak into the base repo.
* Manifest files describe desired state; providers reconcile the system.
* Bootstrap + setup scripts are idempotent—rerun them after changes.

For deeper context see `DEV.md`.
