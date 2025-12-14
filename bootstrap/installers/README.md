# bootstrap/installers

Executable scripts in this directory are run by the `custom` provider during `bootstrap/install-packages.sh`.

## Contract

* File extension: `.sh`
* Shebang: `#!/usr/bin/env bash`
* Must be idempotent (safe to run repeatedly)
* Should log via `log::info|warn|error`
* May assume `$DOTFILES` and `$OS` are exported

Scripts run in lexical order, first from `bootstrap/installers/`, then from the selected overlay’s `bootstrap/installers/` directory (if it exists).

## Current Installers

| Script | Purpose |
| --- | --- |
| `rust.sh` | Installs `rustup`, stable toolchain, and ensures `$HOME/.cargo/bin` is available. |
| `uv.sh` | Installs / updates `uv` for Python tooling. |

Add a new installer when a tool cannot be expressed via package manifests (e.g., curl-bash installers, language-specific managers).
