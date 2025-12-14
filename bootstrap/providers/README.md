# bootstrap/providers

Providers translate manifest intent into concrete package installations.

Every provider exposes a `::<action>` API (e.g., `brew::install`) consumed by `bootstrap/install-packages.sh`.

## Available Providers

| File | Role |
| --- | --- |
| `common.sh` | Manifest helpers (`collect_manifests`, `read_manifest_to_array`). Overlay-aware. |
| `brew.sh` | Installs Homebrew (if missing), loads its env, installs formulas + casks (macOS + Linux). |
| `apt.sh` | Installs system packages via `apt-get` on Linux (used for prerequisites). |
| `custom.sh` | Executes installer scripts under `bootstrap/installers/` (base + overlay). |

## Writing a Provider

1. Create `<name>.sh` in this directory.
2. Source `bootstrap/lib.sh` and `providers/common.sh` as needed.
3. Provide an entry function (e.g., `name::install`).
4. Keep it idempotent and log actions via `log::*`.
5. Hook it into `install-packages.sh`.

Prefer manifests whenever possible; providers should remain thin translators.
