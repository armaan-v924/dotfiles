# Setup Scripts

Scripts in this directory run during the final stage of `bootstrap/bootstrap.sh`
(see `bootstrap/setup.sh`). They are typically interactive and should be
idempotent so re-running bootstrap is safe.

## Contract

* Shebang: `#!/usr/bin/env bash`
* Log via `log::info|warn|error`
* Guard repeated work (e.g., use markers like `dotfiles.marker`)
* Assume `$DOTFILES` and `$DOTFILES_OVERLAY_DIR` are exported

The overlay’s `setup/` directory is processed after the base directory, so work
overrides can add their own scripts.

Use this folder for tasks that need guided setup, such as:

* Configuring git identity (`setup/git.sh`)
* Generating SSH keys
* Initializing credential helpers / GPG
* Machine- or overlay-specific tweaks that require prompts
