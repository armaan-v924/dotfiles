# shellcheck shell=bash
# colors.sh — sourceable ANSI color + style variables for bash scripts.
# Usage:
#   source "/path/to/colors.sh"
#   printf "%sHello%s\n" "$BOLD$GREEN" "$RESET"
#
# Controls:
#   NO_COLOR=1      -> disable color
#   FORCE_COLOR=1   -> force enable color (even if not TTY)
#   CLICOLOR=0      -> disable (common convention)
#   CLICOLOR_FORCE=1-> force enable (common convention)

__colors_init() {
  # Default: assume no color
  local enable=0

  # Respect common disable signals
  if [[ -n "${NO_COLOR-}" ]]; then
    enable=0
  elif [[ "${CLICOLOR-}" == "0" ]]; then
    enable=0
  elif [[ "${TERM-}" == "dumb" ]]; then
    enable=0
  else
    # Enable if stdout is a TTY
    if [[ -t 1 ]]; then
      enable=1
    fi
  fi

  # Respect force signals
  if [[ "${FORCE_COLOR-}" == "1" || -n "${CLICOLOR_FORCE-}" ]]; then
    enable=1
  fi

  if (( enable )); then
    # Escape char
    local esc=$'\033'

    # Reset + effects
    export RESET="${esc}[0m"
    export BOLD="${esc}[1m"
    export DIM="${esc}[2m"
    export ITALIC="${esc}[3m"
    export UNDERLINE="${esc}[4m"
    export BLINK="${esc}[5m"
    export REVERSE="${esc}[7m"
    export HIDDEN="${esc}[8m"
    export STRIKE="${esc}[9m"

    # Basic 8 colors (foreground)
    export BLACK="${esc}[30m"
    export RED="${esc}[31m"
    export GREEN="${esc}[32m"
    export YELLOW="${esc}[33m"
    export BLUE="${esc}[34m"
    export MAGENTA="${esc}[35m"
    export CYAN="${esc}[36m"
    export WHITE="${esc}[37m"

    # Bright (high-intensity) foreground
    export BRIGHT_BLACK="${esc}[90m"
    export BRIGHT_RED="${esc}[91m"
    export BRIGHT_GREEN="${esc}[92m"
    export BRIGHT_YELLOW="${esc}[93m"
    export BRIGHT_BLUE="${esc}[94m"
    export BRIGHT_MAGENTA="${esc}[95m"
    export BRIGHT_CYAN="${esc}[96m"
    export BRIGHT_WHITE="${esc}[97m"

    # Backgrounds (8 colors)
    export BG_BLACK="${esc}[40m"
    export BG_RED="${esc}[41m"
    export BG_GREEN="${esc}[42m"
    export BG_YELLOW="${esc}[43m"
    export BG_BLUE="${esc}[44m"
    export BG_MAGENTA="${esc}[45m"
    export BG_CYAN="${esc}[46m"
    export BG_WHITE="${esc}[47m"

    # Bright backgrounds
    export BG_BRIGHT_BLACK="${esc}[100m"
    export BG_BRIGHT_RED="${esc}[101m"
    export BG_BRIGHT_GREEN="${esc}[102m"
    export BG_BRIGHT_YELLOW="${esc}[103m"
    export BG_BRIGHT_BLUE="${esc}[104m"
    export BG_BRIGHT_MAGENTA="${esc}[105m"
    export BG_BRIGHT_CYAN="${esc}[106m"
    export BG_BRIGHT_WHITE="${esc}[107m"

    # Handy semantic aliases (feel free to change)
    export INFO="${CYAN}"
    export WARN="${YELLOW}${BOLD}"
    export ERROR="${RED}${BOLD}"
    export OK="${GREEN}${BOLD}"
    export MUTED="${DIM}${BRIGHT_BLACK}"

  else
    # No color: export empty strings so scripts can still concatenate safely.
    export RESET="" BOLD="" DIM="" ITALIC="" UNDERLINE="" BLINK="" REVERSE="" HIDDEN="" STRIKE=""
    export BLACK="" RED="" GREEN="" YELLOW="" BLUE="" MAGENTA="" CYAN="" WHITE=""
    export BRIGHT_BLACK="" BRIGHT_RED="" BRIGHT_GREEN="" BRIGHT_YELLOW="" BRIGHT_BLUE="" BRIGHT_MAGENTA="" BRIGHT_CYAN="" BRIGHT_WHITE=""
    export BG_BLACK="" BG_RED="" BG_GREEN="" BG_YELLOW="" BG_BLUE="" BG_MAGENTA="" BG_CYAN="" BG_WHITE=""
    export BG_BRIGHT_BLACK="" BG_BRIGHT_RED="" BG_BRIGHT_GREEN="" BG_BRIGHT_YELLOW="" BG_BRIGHT_BLUE="" BG_BRIGHT_MAGENTA="" BG_BRIGHT_CYAN="" BG_BRIGHT_WHITE=""
    export INFO="" WARN="" ERROR="" OK="" MUTED=""
  fi
}

# Initialize immediately on source.
__colors_init

# Optional: allow re-init after changing env vars (NO_COLOR/FORCE_COLOR/etc.)
colors::reinit() { __colors_init; }

