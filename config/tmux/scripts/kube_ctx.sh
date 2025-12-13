#!/usr/bin/env sh
# Prints current kubectl context, or nothing if unavailable.
# Intended for tmux status bar usage.

set -eu

# Fast exit if kubectl not present
command -v kubectl >/dev/null 2>&1 || exit 0

ctx="$(kubectl config current-context 2>/dev/null || true)"
[ -n "$ctx" ] || exit 0

# Optional shortening:
# - drop common prefixes
# - keep it readable but compact
ctx="${ctx##*/}"     # strip paths
ctx="${ctx##*:}"     # strip cluster prefixes if present

printf "󱃾 %s" "$ctx"
