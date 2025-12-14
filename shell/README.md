# Shell Assets

Shared shell utilities live here. They are sourced by bootstrap scripts and the zsh startup files.

## Files

| File | Purpose |
| --- | --- |
| `colors.sh` | ANSI color definitions used by the logger + prompts. |
| `log.sh` | `log::info|warn|error|debug` helpers with Nerd Font icons. |
| `zsh/` | Partitioned zsh startup files + helper scripts. |
| `utils/` | Reusable shell functions sourced recursively by zsh. |

`log.sh` initializes itself on `source`, respecting env vars such as `LOG_LEVEL`, `LOG_TS`, `LOG_NAME`, and `LOG_ICONS`. Use it instead of `echo` in scripts for consistent output.

Anything shell-related but not specific to zsh (shared functions, helper scripts) should live alongside these files (ideally under `utils/` for automatic loading).
