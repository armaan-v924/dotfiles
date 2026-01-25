# Overlays

Overlays are separate, ignored directories that layer environment-specific config (e.g., work) on top of the base dotfiles.

## Rules

* Each overlay lives under `overlays/<name>/`.
* Real overlays are ignored by `.git`; template overlays (e.g., `work.example`) remain tracked for reference.
* Overlays are typically their own Git repositories.
* The structure mirrors the base repo (`manifests/`, `shell/`, `bootstrap/installers/`, etc.).

## How They're Used

1. `bootstrap/bootstrap.sh` discovers overlays via `bootstrap/overlay.sh`.
2. The selected overlay is persisted to `.overlay` (gitignored) for use by shell sessions.
3. The selected overlay sets `DOTFILES_OVERLAY` + `DOTFILES_OVERLAY_DIR` during bootstrap.
4. Providers load overlay manifests in addition to base manifests.
5. `bootstrap/installers` and `setup/` directories are processed again inside the overlay.
6. Optional overlay files (e.g., `shell/env.sh`, `git/gitconfig`) are sourced/included when present.
7. Shell startup hooks the active overlay: `environment.sh` sources overlay `*.env` (skipping `.no-source`), `profile.sh` and `login.sh` source overlay counterparts, and `run_commands.sh` layers overlay `shell/utils`, `shell/scripts`, and interactive tweaks in order.

## Overlay Selection Priority

When shell sessions start, the active overlay is determined by:

1. **`DOTFILES_OVERLAY_DIR` env var** - Explicit path override (e.g., `export DOTFILES_OVERLAY_DIR=~/custom/overlay`)
2. **`.overlay` file** - Persisted bootstrap selection (written by `bootstrap.sh`)
3. **`DOTFILES_OVERLAY` env var** - Name-based override (e.g., `export DOTFILES_OVERLAY=work`)
4. **Auto-discovery** - If exactly one overlay exists under `overlays/`, use it automatically

To change overlays, either:
- Re-run `bootstrap/bootstrap.sh` and select a different overlay, or
- Manually edit `.overlay` to contain the overlay name, or
- Set `DOTFILES_OVERLAY` or `DOTFILES_OVERLAY_DIR` in your environment

## Creating an Overlay

```bash
cd ~/.dotfiles/overlays
git clone git@work.git/dotfiles-overlay.git work
```

Populate only the sections you need. Example layout:

```
overlays/work/
├── manifests/
│   ├── packages.darwin
│   └── packages.linux
├── bootstrap/
│   └── installers/
├── shell/
│   ├── env.sh                    # Common env (both bootstrap + shell)
│   ├── bootstrap/
│   │   ├── .no-source           # Marker: skip during shell startup
│   │   └── build.env            # Bootstrap-only env (build flags, etc.)
│   ├── contexts/
│   │   ├── .no-source           # Marker: skip during auto-loading
│   │   └── uv.env               # On-demand env (source manually)
│   ├── utils/                   # Auto-loaded shell utilities
│   ├── scripts/                 # Auto-loaded shell scripts
│   └── zsh/
│       ├── profile.sh           # Login-time PATH/exports
│       └── run_commands.sh      # Interactive config (aliases, etc.)
└── git/
    └── gitconfig
```

Keep secrets, credentials, and corporate tooling isolated inside the overlay repo.

### Environment File Loading

**`shell/env.sh`** - Common environment variables loaded by both bootstrap and shell sessions. Use for shared credentials, paths, and settings.

**`shell/bootstrap/build.env`** - Bootstrap-only environment variables (e.g., build flags, installer configuration). The `.no-source` marker prevents shell sessions from loading this.

**`shell/contexts/`** - On-demand environment files for specific tools or contexts. The `.no-source` marker prevents auto-loading. Source explicitly when needed:
```bash
source "$DOTFILES_OVERLAY_DIR/shell/contexts/uv.env"
```

### Tool-Specific Environment Wrapper Example

For tools that need different environment variables in different contexts (e.g., `uv` needing different `AWS_PROFILE`), use a function wrapper to set defaults while preserving completions:

```bash
# In overlays/work/shell/zsh/run_commands.sh

# Wrapper for uv with artifacts AWS profile
uv() {
  AWS_PROFILE=saas-artifacts-root command uv "$@"
}

# Load uv completions and apply to wrapper
eval "$(command uv generate-shell-completion zsh)"
compdef uv=uv

# One-off override: AWS_PROFILE=bastion-sso uv sync
```

This pattern works for any tool where you need to set environment variables while keeping tab completions intact.
