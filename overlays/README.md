# Overlays

Overlays are separate, ignored directories that layer environment-specific config (e.g., work) on top of the base dotfiles.

## Rules

* Each overlay lives under `overlays/<name>/`.
* Real overlays are ignored by `.git`; template overlays (e.g., `work.example`) remain tracked for reference.
* Overlays are typically their own Git repositories.
* The structure mirrors the base repo (`manifests/`, `shell/`, `bootstrap/installers/`, etc.).

## How They’re Used

1. `bootstrap/bootstrap.sh` discovers overlays via `bootstrap/overlay.sh`.
2. The selected overlay sets `DOTFILES_OVERLAY` + `DOTFILES_OVERLAY_DIR`.
3. Providers load overlay manifests in addition to base manifests.
4. `bootstrap/installers` and `setup/` directories are processed again inside the overlay.
5. Optional overlay files (e.g., `shell/env.sh`, `git/gitconfig`) are sourced/included when present.

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
│   ├── env.sh
│   └── interactive.zsh
└── git/
    └── gitconfig
```

Keep secrets, credentials, and corporate tooling isolated inside the overlay repo.
