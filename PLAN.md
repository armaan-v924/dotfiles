# PLAN.md — Cross‑Platform, Work‑Safe Dotfiles Architecture

## Purpose

This document defines the architecture, structure, and operating principles for a **reproducible, cross‑platform (macOS + Linux)** dotfiles system with a **clean separation between personal and work configuration**.

Goals:

* Deterministic setup on a fresh machine
* Minimal persistent state outside Git
* Public personal dotfiles repo
* Work configuration maintained in a **separate Git repo**, nested as an ignored overlay
* Clean Zsh startup partitioning
* Modern tooling defaults (uv, ruff, etc.)

Non‑goals:

* Preserving legacy local state
* One‑off snowflake setup steps
* Mixing work credentials or tooling into personal repos

---

## High‑Level Architecture

```
$HOME
├── .dotfiles/              # Personal / public dotfiles (GitHub)
│   ├── bootstrap/
│   ├── shell/
│   ├── config/
│   ├── manifests/
│   ├── bin/
│   ├── overlays/
│   │   ├── work/            # Work overlay (SEPARATE git repo, ignored)
│   │   │   └── .git/
│   │   └── work.example/    # Tracked template
│   └── .git/
└── (home directory remains disposable)
```

Key ideas:

* `.dotfiles` is the **source of truth**
* `$HOME` is disposable
* `overlays/work` is:

  * ignored by the personal repo
  * its own independent Git repository
  * owned and maintained under a work account

---

## Repository Responsibilities

### Personal Dotfiles Repo (`~/.dotfiles`)

Responsible for:

* Base shell configuration
* Cross‑platform logic
* Tooling defaults
* Package manifests (personal)
* Bootstrap and symlink logic
* Extension hooks for overlays

Explicitly NOT responsible for:

* Work credentials
* Internal tooling
* Corporate network config
* Secrets

### Work Overlay Repo (`overlays/work`)

Responsible for:

* Work‑specific environment variables
* Work shell extensions
* Work package manifests
* Work git identity / signing rules
* Any compliance‑sensitive configuration

This repo:

* Has its own `.git/`
* Is ignored by the personal repo
* Can safely be pushed to work Git hosting

---

## Git Ignore Strategy

In personal dotfiles repo:

```
overlays/*
!overlays/*.example
```

Effect:

* All real overlays are ignored
* Example templates remain tracked
* Nested `.git/` directories are completely invisible to the personal repo

This is **not** a submodule.

---

## Zsh Startup Partitioning

Zsh files are strictly partitioned by responsibility.

### `.zshenv` — Always

Runs for **every zsh invocation**, including non‑interactive shells.

Rules:

* Must be fast
* No aliases
* No interactive logic

Responsibilities:

* Define `$DOTFILES`
* Define overlay profile
* Minimal PATH setup

```zsh
export DOTFILES="$HOME/.dotfiles"
: ${DOTFILES_PROFILE:=personal}
export DOTFILES_PROFILE

export XDG_CONFIG_HOME="$HOME/.config"
export PATH="$DOTFILES/bin:$PATH"
```

---

### `.zprofile` — Login shells

Runs once per login session.

Responsibilities:

* OS detection
* PATH setup
* Language/runtime env vars
* Load overlay environment

```zsh
case "$(uname)" in
  Darwin) export OS=darwin ;;
  Linux)  export OS=linux ;;
esac

source "$DOTFILES/shell/env/common.env"
source "$DOTFILES/shell/zsh/paths.zsh"

OVERLAY="$DOTFILES/overlays/work"
[[ -f "$OVERLAY/shell/env.zsh" ]] && source "$OVERLAY/shell/env.zsh"
```

---

### `.zshrc` — Interactive shells

Runs for interactive shells only.

Responsibilities:

* Prompt
* Aliases
* Functions
* Completions
* Optional work interactive extensions

```zsh
[[ -o interactive ]] || return

source "$DOTFILES/shell/zsh/aliases.zsh"
source "$DOTFILES/shell/zsh/functions.zsh"
source "$DOTFILES/shell/zsh/completions.zsh"

OVERLAY="$DOTFILES/overlays/work"
[[ -f "$OVERLAY/shell/interactive.zsh" ]] && source "$OVERLAY/shell/interactive.zsh"
```

---

### `.zlogin`

Unused by default.
Reserved for rare, once‑per‑session behavior.

---

## Overlay Contract (Interface)

The personal repo defines **hooks**, not implementations.

If the following files exist, they are sourced:

```
overlays/work/
├── shell/
│   ├── env.zsh            # login‑time env vars
│   └── interactive.zsh    # interactive shell additions
├── manifests/
│   ├── packages.darwin
│   └── packages.linux
├── git/
│   └── gitconfig
└── bootstrap/
    └── bootstrap.sh
```

The base repo never assumes their presence.

---

## Git Configuration Strategy

### Public `~/.gitconfig`

```ini
[include]
  path = ~/.gitconfig-local

[includeIf "gitdir:~/work/"]
  path = ~/.dotfiles/overlays/work/git/gitconfig
```

Effects:

* Personal identity everywhere by default
* Work identity only inside `~/work/**`
* Work config lives entirely in work repo

---

## Package Management ("requirements-work.txt" Pattern)

### Base manifests (personal repo)

```
manifests/
├── packages.common
├── packages.darwin
└── packages.linux
```

### Overlay manifests (work repo)

```
overlays/work/manifests/
├── packages.darwin
└── packages.linux
```

Bootstrap flow:

1. Install common packages
2. Install OS‑specific packages
3. If overlay exists, install overlay packages

This keeps work tooling opt‑in and isolated.

---

## Tooling Baseline

### Python

* `uv` only (no pip / conda)
* Global config: `~/.config/uv/uv.toml`
* Per‑project config: `pyproject.toml`

### Formatting & Linting

* `ruff` for:

  * linting
  * formatting
  * import sorting

Deprecated tools:

* black
* isort
* flake8

### Rust

* Scripts placed in `bootstrap/installers/` run automatically via the custom provider during bootstrap.
* `bootstrap/installers/rust.sh` installs `rustup` + stable toolchain (clippy, rustfmt) whenever `cargo` is missing.
* `$HOME/.cargo/bin` is added to `PATH` so `cargo` and `rust-analyzer` are always available.

---

## Symlink Strategy

* Explicit symlinks only
* Created by `bootstrap/link.sh`
* Public repo only links public files
* Work repo links work‑specific files

No symlinks from tracked files → ignored paths.

---

## Bootstrap Flow

### Pre-Bootstrap Requirements (Fresh Machine)

On a brand-new machine, **before any dotfiles logic can run**, the following must be true:

* `git` is installed
* Network access is available
* Authentication to:

  * personal Git hosting (for `~/.dotfiles`)
  * work Git hosting (for work overlay repo)

This is an unavoidable bootstrapping step and must be handled explicitly.

Recommended approach:

* Use system package manager or OS defaults to install `git`

  * macOS: Xcode Command Line Tools (`xcode-select --install`)
  * Linux: distro package manager
* Authenticate **before cloning overlays** (SSH keys, SSO, or HTTPS tokens as required by work)

The installer must assume **no prior configuration exists**.

---

### Snapshotting Preexisting State (Safety & Reproducibility)

If the bootstrap is run on a machine that is *not* pristine, the installer should:

* Detect existing files before overwriting or linking
* Snapshot them to a timestamped archive directory, e.g.:

  * `~/.dotfiles-backups/YYYY-MM-DD/`
* Never silently overwrite:

  * shell configs (`.zshrc`, `.zprofile`, etc.)
  * git config files
  * XDG config directories

This ensures:

* Full reproducibility
* Easy rollback
* No hidden dependence on legacy state

---

### Fresh Personal Machine

```bash
git clone git@github.com:you/dotfiles.git ~/.dotfiles
~/.dotfiles/bootstrap/bootstrap.sh
```

### Work Machine

```bash
git clone git@github.com:you/dotfiles.git ~/.dotfiles
cd ~/.dotfiles/overlays

git clone git@work.git/dotfiles-work.git work

~/.dotfiles/bootstrap/bootstrap.sh
~/.dotfiles/overlays/work/bootstrap/bootstrap.sh
```

Bootstrap scripts must be:

* Idempotent
* Safe to rerun
* Non‑destructive

---

## Operating Philosophy

* Backup for safety → delete for clarity → rebuild with intent
* Treat machines as cattle, not pets
* Prefer explicit structure over clever automation
* If something can’t be reproduced, it doesn’t belong

---

## End State

After implementation:

* New machine → productive in < 30 minutes
* Same dotfiles on macOS and Linux
* Clean personal/work separation
* Zero fear of accidental credential leakage
* Dotfiles repo is documentation, not just config

---

**This document is the contract.**
Changes to structure should update this file first.
