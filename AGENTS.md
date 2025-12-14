# AGENTS.md — Collaborative Context for Automation Agents

This repository is intentionally minimal and structured so any automation agent
or future collaborator can reason about it quickly. This document summarises the
ground rules extracted from `DEV.md` and the directory-level READMEs.

## North Star

* **Single source of truth:** `~/.dotfiles` owns the full environment.
* **Overlay isolation:** Work/private config sits in `overlays/<name>/` (ignored
  by the main repo, usually its own Git repo).
* **Reproducibility:** A fresh machine + bootstrap must converge without manual
  tinkering; scripts are idempotent.
* **Minimalism:** tmux is the UI anchor, starship prompt stays quiet, Neovim
  config is modular and discoverable.

## Repository Map

| Path | Notes |
| --- | --- |
| `DEV.md` | Canonical development contract (design, structure, roadmap). |
| `bootstrap/` | Overlay selection + package/install orchestration. |
| `config/nvim/` | Lazy-managed Neovim; tmux-aligned colors, Space leader. |
| `config/tmux/` | Always-on tmux (login shells auto attach), subtle UI. |
| `manifests/` | Package intent for providers (brew/apt/casks). |
| `overlays/` | Environment-specific repos mirroring base layout. |
| `setup/` | Interactive/idempotent scripts (git, ssh, etc.). |
| `shell/` | Logger, colors, zsh partitioning, reusable utils. |

Every major directory now has a README describing its contract.

## Operating Principles for Agents

1. **Respect overlays:** Never hardcode work secrets; use hooks provided in
   `overlays/<name>/`. Overlay manifests mirror base manifests.
2. **Prefer manifests/providers:** Don’t install packages ad-hoc; edit the
   relevant manifest and let bootstrap reconcile.
3. **Logging:** Use `log::info|warn|error` from `shell/log.sh`. No raw `echo`.
4. **Idempotency:** Installers, providers, setup scripts must handle repeated
   runs gracefully.
5. **Zsh partitioning:** `.zshenv` (`environment.sh`) stays minimal; interactive
   logic belongs in `run_commands.sh`. `login.sh` is reserved for rare
   once-per-session behavior (currently auto-tmux).
6. **Neovim extensibility:** Add plugins via modular specs under
   `config/nvim/lua/dotfiles/plugins/`; keep `lazy-lock.json` updated.
7. **Documentation first:** Update `DEV.md` and relevant READMEs when changing
   contracts or flows. `RECOVERY.md` is the fresh-machine playbook.

## Quick Reference Tables

### Bootstrap Flow

1. `bootstrap.sh` → choose overlay (`bootstrap/overlay.sh`).
2. `install-packages.sh` → run providers (`brew`, `apt`, `custom`).
3. `link.sh` → symlink configs with backups.
4. `setup.sh` → run base + overlay setup scripts.

### Providers & Installers

| Provider | Purpose |
| --- | --- |
| `brew.sh` | Ensure Homebrew exists, install formulas + casks. |
| `apt.sh` | Install Linux system packages. |
| `custom.sh` | Execute scripts under `bootstrap/installers/`. |

Current installers: `rust.sh`, `uv.sh`. Add more only when manifests can’t
express the install.

### Shell Behavior

* `environment.sh` → sourced for every shell (`~/.zshenv`).
* `profile.sh` → login-only exports (e.g., PATH additions).
* `run_commands.sh` → interactive config (fzf-tab, zoxide overrides, utility sourcing).
* `login.sh` → `exec tmux` for login shells unless `DOTFILES_DISABLE_AUTO_TMUX` is set.

`shell/utils/` is sourced recursively; drop helper functions there.

## Pending / Future Work (per DEV.md)

* Neovim polish (LSP baseline, plugin wiring) — partially done but keep modular.
* fzf/fd/rg integration across shell + editor (currently using fzf-tab and
  Neovim integrations; ensure parity).
* SSH setup provider (`setup/ssh.sh`) — not yet implemented.
* Optional non-brew providers (mas, uv tool/pipx, cargo) if needed.
* Documentation polish (README/RECOVERY done; add more as flows change).

## Contact Points

* Owner: Armaan.
* For work-specific questions, refer to the overlay repo owner.

When in doubt, re-read `DEV.md`: it is the contract. Update it first if you
plan to diverge.
