# DEV.md — Dotfiles Development Contract

This document supersedes `PLAN.md` and `CODEX.md`. It is the living contract for
how these dotfiles are designed, extended, and maintained.

---

## 1. Philosophy

* **Machines are disposable.** `~/.dotfiles` is the only source of truth.
* **Reproducibility first.** A fresh macOS/Linux install + bootstrap must reach
  the same end state with no hand-editing.
* **Overlay isolation.** Work/private configuration lives in ignored overlay
  repos (`overlays/<name>/`) that mirror the base layout.
* **Minimal surface area.** tmux is the UI anchor; prompts and configs avoid
  noisy customization. Features must earn their place.
* **Documentation > tribal knowledge.** Every contract change updates this file
  (and relevant READMEs). `RECOVERY.md` captures the rebuild playbook.
* **Idempotency + logging.** All scripts log via `log::*` and handle repeated
  runs gracefully.

---

## 2. Design Spec

### 2.1 Bootstrap Pipeline

1. **Overlay selection:** `bootstrap/overlay.sh` discovers overlays; user selects
   one (defaults to `personal` in non-interactive contexts). Overlay env exports
   `DOTFILES_OVERLAY` and `DOTFILES_OVERLAY_DIR`.
2. **Package install:** `bootstrap/install-packages.sh` sources providers
   (brew/apt/custom) and applies manifests from both base and overlay.
3. **Linking:** `bootstrap/link.sh` symlinks tracked files into `$HOME`,
   snapshotting conflicts.
4. **Setup:** `bootstrap/setup.sh` runs `setup/*.sh` (base then overlay). Scripts
   are responsible for any interactive steps (git identity, ssh keys, etc.).

### 2.2 Providers & Manifests

* Manifests (`manifests/*.txt`) list one package per line; overlays can provide
  files with the same name. Combined sets are deduplicated and sorted.
* Providers translate manifests into actions:
  * `brew.sh` — install Homebrew (if needed), formulas, and casks.
  * `apt.sh` — install system packages on Linux.
  * `custom.sh` — execute scripts under `bootstrap/installers/` (base + overlay).
* Installers (`bootstrap/installers/*.sh`) are for tooling not available via
  package managers (e.g., `rustup`, `uv`). Keep them stateless and logged.

### 2.3 Shell Contract

* `.zshenv` → `shell/zsh/environment.sh`: declare `$DOTFILES`, light PATH seeds.
* `.zprofile` → `shell/zsh/profile.sh`: login-time PATH/runtime exports.
* `.zshrc` → `shell/zsh/run_commands.sh`: interactive setup (fzf-tab, zoxide,
  aliases, completions, `shell/utils/**/*.sh` auto-sourcing).
* `.zlogin` → `shell/zsh/login.sh`: once-per-login behavior (auto `tmux`).
* `shell/log.sh` provides `log::info|warn|error|debug`; use it everywhere.
* `shell/utils/` contains helper scripts sourced recursively for reuse.

### 2.4 tmux + Neovim

* tmux is always-on for login shells. `config/tmux/tmux.conf` defines prefix,
  status bar, scripts, and matches the Neovim color palette.
* Neovim (lazy.nvim) lives under `config/nvim/`. Structure:

  ```
  init.lua
  lazy-lock.json
  lua/dotfiles/
    core/      # opts, autocmds, keymaps
    plugins/   # modular specs (LSP, telescope, etc.)
    utils/
    overlay.lua
  ```

* Leader is `<Space>`; which-key groups commands; Mason manages LSPs.
* Colors and UI mirror tmux/starship for consistency.

### 2.5 Overlays

* Located under `overlays/<name>/` (ignored; usually their own Git repo).
* May provide manifests, installers, setup scripts, shell env, gitconfig, etc.
* Overlay directories mirror base structure; only populate what's needed.
* Bootstrap writes the selected overlay name to `.overlay` (gitignored) to persist
  the choice across shell sessions.
* Shell startup reads `.overlay` to determine which overlay to apply (if any).
* Priority: `DOTFILES_OVERLAY_DIR` env var → `.overlay` file → `DOTFILES_OVERLAY`
  env var → auto-discovery (single overlay only).

### 2.6 Documentation & Support Files

* `README.md` — high-level entry + repo layout.
* `RECOVERY.md` — fresh machine playbook.
* `AGENTS.md` — quick reference for automation.
* Directory-level READMEs explain local contracts (bootstrap, providers,
  installers, config/*, manifests, overlays, setup, shell, shell/zsh).

---

## 3. Current Structure Overview

```
.dotfiles/
├── AGENTS.md
├── DEV.md
├── README.md
├── RECOVERY.md
├── bootstrap/
│   ├── README.md
│   ├── bootstrap.sh
│   ├── install-packages.sh
│   ├── overlay.sh
│   ├── link.sh
│   ├── setup.sh
│   ├── installers/
│   │   ├── README.md
│   │   ├── rust.sh
│   │   └── uv.sh
│   └── providers/
│       ├── README.md
│       ├── apt.sh
│       ├── brew.sh
│       ├── common.sh
│       └── custom.sh
├── config/
│   ├── nvim/ (README + init.lua + lua/dotfiles/*)
│   └── tmux/ (README + tmux.conf + scripts/)
├── manifests/ (README + manifests)
├── overlays/ (README + per-overlay repos)
├── setup/ (README + scripts e.g., git.sh)
├── shell/
│   ├── README.md
│   ├── colors.sh
│   ├── log.sh
│   ├── utils/ (README + helpers)
│   └── zsh/ (README + environment/profile/run/login)
└── bin/, config assets, etc.
```

Refer to individual READMEs for per-directory responsibilities and contracts.

---

## 4. Planned Improvements

1. **Neovim polish:** Continue modular plugin work—ensure LSP setup uses
   `vim.lsp.config`, maintain Mason integration, and keep which-key mappings
   discoverable. Expand docs/keybind tables as needed.
2. **fzf/fd/rg parity:** zsh uses fzf-tab with previews; ensure Neovim
   integrations (telescope, etc.) mirror the same keybinds and tmux-style theme.
3. **SSH setup provider:** Add `setup/ssh.sh` to automate key generation,
   `~/.ssh/config`, and overlay-aware host aliases.
4. **Additional providers:** Evaluate optional providers (MAS, `uv tool`, `pipx`,
   `cargo`) for workflows not covered by brew/apt/custom.
5. **Overlay templates:** Provide richer `overlays/<name>.example` scaffolding
   for new overlays (env files, manifests, setup scripts).
6. **Tests / linting hooks:** Consider lightweight shell linting or CI scripts
   to ensure bootstrap pieces stay working.

All future work must honor the philosophy above. Update this document first when
changing contracts or architecture.
