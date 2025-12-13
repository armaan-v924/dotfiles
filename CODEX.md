# Dotfiles / Bootstrap Handoff

**Owner:** Armaan
**State:** Post–fresh OS reset, core environment rebuilt
**Goal:** Fully reproducible dev environment across macOS + Linux using overlays

---

## High-Level Architecture

This dotfiles repo is designed around **three core ideas**:

1. **Reproducibility first**

   * A fresh machine + this repo should converge to the same environment.
   * Existing configs are backed up before being replaced.

2. **Overlay-based environments**

   * Base dotfiles are personal + generic.
   * Environment-specific config (e.g. work) lives in overlays.
   * Overlays are optional and selected at bootstrap time.

3. **Provider-based package installs**

   * Package managers are treated as providers (brew, apt, etc.).
   * Manifests describe *what* to install, providers describe *how*.

---

## Current Directory Layout (Important)

```
.dotfiles/
  bin/                     # user scripts (PATH)
  bootstrap/
    bootstrap.sh
    install-packages.sh    # orchestrator
    lib.sh                 # OS detection + logging
    providers/
      common.sh            # manifest parsing + overlay logic
      brew.sh              # Homebrew provider (macOS + Linux)
      apt.sh               # apt provider (Linux system deps)
  config/
    tmux/
      tmux.conf
      scripts/
        cpu.sh
        mem.sh
        os.sh
        repo_path.sh
        kube_ctx.sh
  manifests/
    packages.common        # brew formulae (cross-platform)
    packages.darwin        # brew formulae (macOS only)
    packages.linux         # brew formulae (Linux only)
    casks.darwin           # brew casks (macOS)
    apt.linux              # apt packages (Linux system deps)
  overlays/
    <name>/                # optional, git-ignored in main repo
      manifests/           # same filenames as base manifests
  shell/
    log.sh                 # custom logger (log::info, warn, error)
    colors.sh
    zsh/
      environment.sh
      profile.sh
      run_commands.sh
      login.sh
```

---

## Bootstrap Flow (Current)

1. **Bootstrap entry**

   * `bootstrap.sh` selects overlay (if any) and exports:

     * `DOTFILES`
     * `DOTFILES_OVERLAY_DIR`
     * `OS` (`darwin` or `linux`)

2. **Package installation**

   * `install-packages.sh`:

     * sources `lib.sh`
     * sources provider modules
     * runs providers based on OS:

       * macOS: `brew` → `cask`
       * Linux: `apt` → `brew`

3. **Providers**

   * `providers/common.sh`

     * `manifest_lines`: normalize manifest files
     * `collect_manifests`: base + overlay manifests
     * `read_manifest_to_array`: bash-3.2-safe loading
   * `providers/brew.sh`

     * installs brew if missing
     * loads brew env
     * installs formulae + casks
   * `providers/apt.sh`

     * installs Linux system packages via `apt-get`
     * intended only for system-level deps
   * `providers/custom.sh`

      * executes executable `.sh` scripts located in `bootstrap/installers/`
      * overlay installers run after base installers

**Overlays automatically apply** to all providers by mirroring manifest filenames.

---

## tmux (Status: DONE / v1 locked)

* Always-on tmux (login shells auto-enter tmux)
* Minimal, flat UI (no powerline/pills)
* Subtle pane borders
* Status bar shows:

  * OS icon
  * window list
  * repo-relative path + git branch + dirty state
  * SSH indicator
  * Kubernetes context (only if present)
  * CPU + memory
* All tmux scripts live under `~/.config/tmux/scripts/`
* XDG-compliant

No further tmux work planned unless functionality is missing.

---

## Starship Prompt (Status: DONE / minimal)

Starship is intentionally **extremely minimal** because tmux carries context.

Prompt shows:

* current directory (repo-aware)
* git branch (only)
* error indicator if last command failed
* prompt character

No kube / ssh / metrics in prompt.

---

## What Works Right Now

* Fresh macOS install → bootstrap → working dev environment
* Overlay manifests install additional packages correctly
* Brew + apt coexist cleanly on Linux
* tmux + starship are stable and non-noisy
* Logging is consistent via `log::*`

---

## Known Non-Goals (By Design)

* No “smart” automation magic
* No heavy prompt theming
* No mixing system deps and userland tools
* No platform-specific hacks without isolation

---

## What’s Next (Planned Work)

### 1. Neovim baseline

* Minimal config
* Plugin manager
* LSP + formatting
* fzf integration
* No over-customization

### 2. fzf / fd / ripgrep wiring

* Shell integration
* Neovim integration
* Consistent keybinds

### 3. SSH setup provider

* `setup/ssh.sh`
* Key generation
* `~/.ssh/config`
* GitHub host aliases
* Overlay-aware defaults

### 4. Non-brew providers (optional)

* `mas` (Mac App Store) if needed
* `uv tool` / `pipx` for Python CLIs
* Possibly `cargo` for Rust tools

### 5. Documentation polish

* `RECOVERY.md` (fresh machine → productive)
* Short README explaining overlays + providers

---

## Important Conventions

* **Always use `log::info|warn|error`** (no `echo`)
* **Never assume bash ≥4** (macOS default is 3.2)
* **Overlays must never leak into base repo**
* **Manifests describe intent; providers do the work**

---

## Current Status Summary

> The system is stable, reproducible, and intentionally boring.
> All further work should preserve that property.

This is a good handoff point.
