# Shell Assets

Shared shell utilities live here. They are sourced by bootstrap scripts and the zsh startup files.

## Files

| File | Purpose |
| --- | --- |
| `colors.sh` | ANSI color definitions used by the logger + prompts. |
| `log.sh` | `log::info|warn|error|debug` helpers with Nerd Font icons. |
| `overlays.sh` | Helper to discover active overlays for shell startup sourcing. |
| `zsh/` | Partitioned zsh startup files + helper scripts. |
| `utils/` | Reusable shell functions sourced recursively by zsh. |
| `scripts/` | Interactive shell helpers sourced by `run_commands.sh` (base + overlay). |

`log.sh` initializes itself on `source`, respecting env vars such as `LOG_LEVEL`, `LOG_TS`, `LOG_NAME`, and `LOG_ICONS`. Use it instead of `echo` in scripts for consistent output.

Anything shell-related but not specific to zsh (shared functions, helper scripts) should live alongside these files (ideally under `utils/` for automatic loading).

## The `.no-source` Pattern

Place a `.no-source` marker file in any directory to prevent its contents from being auto-loaded during shell startup:

```
shell/contexts/
├── .no-source        # Marker file
├── uv.env            # NOT auto-loaded
└── bastion.env       # NOT auto-loaded
```

This works for:
- `*.env` files (via `environment.sh`)
- `*.sh` scripts (via `run_commands.sh`)

The marker file is checked recursively - any file in a directory (or subdirectory) containing `.no-source` will be skipped during auto-loading. Files must be sourced explicitly when needed.
