# Bootstrap

Bootstrap scripts converge a fresh machine onto the desired state.

## Flow

1. `bootstrap.sh` selects/applies an overlay, then runs the phases below.
2. `install-packages.sh` loads providers (`brew`, `apt`, `custom`) and installs packages from manifests + overlay manifests.
3. `link.sh` symlinks tracked configs into `$HOME`, backing up existing files when needed.
4. `setup.sh` runs non-interactive setup scripts under `setup/` and the overlay’s `setup/` (if present).

All scripts are safe to rerun; they log via `shell/log.sh`.

## Key Files

| File | Description |
| --- | --- |
| `bootstrap.sh` | Entry point; handles overlay selection + orchestration. |
| `install-packages.sh` | Provider dispatcher (brew/apt/custom). |
| `overlay.sh` | Overlay discovery + environment exports. |
| `link.sh` | Deterministic symlink creation with backups. |
| `setup.sh` | Runs setup scripts (base + overlay). |
| `providers/` | Package manager integrations. |
| `installers/` | Custom installers consumed by the `custom` provider. |

Add new functionality by extending manifests, providers, or installers—*not* by editing system files manually.
