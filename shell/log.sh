# shellcheck shell=bash
# log.sh — minimal logging helpers using Nerd Font icons.
#
# Requires: colors.sh (for color variables)
# Usage:
#   source colors.sh
#   source log.sh
#
# Controls (env):
#   LOG_LEVEL=info|debug
#   LOG_DEBUG=1          # force debug
#   LOG_TS=1             # timestamps
#   LOG_TS_FORMAT=%H:%M:%S
#   LOG_NAME=1           # prefix script name
#   LOG_ICONS=1          # enable Nerd Font icons
#   LOG_BRACKETS=1       # [INFO] vs INFO:

__log_init() {
  : "${LOG_LEVEL:=info}"
  : "${LOG_DEBUG:=0}"
  : "${LOG_TS:=0}"
  : "${LOG_TS_FORMAT:=%H:%M:%S}"
  : "${LOG_NAME:=1}"
  : "${LOG_ICONS:=1}"
  : "${LOG_BRACKETS:=1}"

  # Nerd Font icons (override if desired)
  # Using widely-supported codicons/octicons
  : "${LOG_ICON_INFO:=󰋼}"    # nf-md-information
  : "${LOG_ICON_OK:=󰄬}"      # nf-md-check
  : "${LOG_ICON_WARN:=󰀪}"    # nf-md-alert
  : "${LOG_ICON_ERROR:=󰅙}"   # nf-md-close_circle
  : "${LOG_ICON_DEBUG:=󰃤}"   # nf-md-bug
}

# ---------- internal helpers ----------

__log__ts() {
  [[ "$LOG_TS" == "1" ]] && date +"$LOG_TS_FORMAT"
}

__log__script() {
  local src
  src="${BASH_SOURCE[1]-$0}"
  printf "%s" "${src##*/}"
}

__log__debug_enabled() {
  [[ "$LOG_LEVEL" == "debug" || "$LOG_DEBUG" == "1" ]]
}

__log__prefix() {
  # args: LABEL COLOR ICON
  local label="$1" color="$2" icon="$3"
  local out="" level=""
  local field_width=12  # includes icon + space + [LEVEL]; tweak if you add longer labels

  [[ "${LOG_TS-0}" == "1" ]]   && out+="${MUTED}$(__log__ts)${RESET} "
  [[ "${LOG_NAME-1}" == "1" ]] && out+="${MUTED}$(__log__script)${RESET} "

  level="[$label]"
  [[ "${LOG_ICONS-1}" == "1" && -n "$icon" ]] && level="$icon $level"

  # pad AFTER the tight brackets, then add exactly one trailing space separator
  level="$(printf '%-*s' "$field_width" "$level") "

  out+="${color}${level}${RESET}"
  printf "%s" "$out"
}

__log__emit() {
  # args: fd prefix message...
  local fd="$1" prefix="$2"
  shift 2

  if [[ "$fd" == "2" ]]; then
    printf "%s%s\n" "$prefix" "$*" >&2
  else
    printf "%s%s\n" "$prefix" "$*"
  fi
}

# ---------- public API ----------

log::info() {
  __log__emit 1 "$(__log__prefix INFO  "$INFO"  "$LOG_ICON_INFO")" "$*"
}

log::ok() {
  __log__emit 1 "$(__log__prefix OK    "$OK"    "$LOG_ICON_OK")" "$*"
}

log::warn() {
  __log__emit 1 "$(__log__prefix WARN  "$WARN"  "$LOG_ICON_WARN")" "$*"
}

log::error() {
  __log__emit 2 "$(__log__prefix ERROR "$ERROR" "$LOG_ICON_ERROR")" "$*"
}

log::debug() {
  __log__debug_enabled || return 0
  __log__emit 1 "$(__log__prefix DEBUG "$MUTED$BOLD" "$LOG_ICON_DEBUG")" "$*"
}

log::die() {
  log::error "$*"
  return 1
}

# ---------- init on source ----------

__log_init

# Allow re-init if env changes
log::reinit() { __log_init; }

