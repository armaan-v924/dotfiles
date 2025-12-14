# Package Manifests

Manifests describe *what* should be installed. Providers (`brew`, `apt`, etc.) interpret these files during `bootstrap/install-packages.sh`.

## Files

| Manifest | Consumed by | Notes |
| --- | --- | --- |
| `packages.common` | `brew` | Brew formulas installed on all platforms. |
| `packages.darwin` | `brew` | macOS-only formulas. |
| `packages.linux` | `brew` | Linux-only formulas (via Homebrew/Linuxbrew). |
| `casks.darwin` | `brew` | macOS GUI apps (`brew install --cask`). |
| `apt.linux` (overlay example) | `apt` | System packages installed with `apt-get`. |

Overlays may define files with the same names (e.g., `overlays/work/manifests/packages.darwin`). Overlay files are merged with the base manifest via `providers/common.sh` (sorted + deduplicated).

## Format

* One package per line.
* `# comments` and blank lines are ignored.
* Files should remain alphabetized for readability (sorting happens automatically during install).

Edit the relevant manifest and rerun bootstrap to reconcile the system.
