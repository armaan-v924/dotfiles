#!/usr/bin/env sh
# Usage: repo_path.sh "/absolute/path"
# Output:
#   repo:subdir  branch*
#   …/last/two
#
# "*" indicates dirty working tree (tracked changes or staged changes).
# Truncates output for tmux status bars.

set -eu

path="${1:-}"
[ -n "$path" ] || { printf "∅"; exit 0; }

max_len="${TMUX_PATH_MAXLEN:-50}"

truncate() {
  s="$1"
  len="${#s}"
  if [ "$len" -le "$max_len" ]; then
    printf "%s" "$s"
  else
    keep=$((max_len - 1))
    printf "…%s" "$(printf "%s" "$s" | awk -v n="$keep" '{print substr($0, length($0)-n+1)}')"
  fi
}

if command -v git >/dev/null 2>&1 \
   && git -C "$path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then

  top="$(git -C "$path" rev-parse --show-toplevel 2>/dev/null || true)"
  repo="$(basename "$top")"

  if [ "$path" = "$top" ]; then
    rel=""
  else
    rel="${path#"$top"/}"
  fi

  # Branch (ignore detached HEAD)
  branch="$(git -C "$path" symbolic-ref --short HEAD 2>/dev/null || true)"

  # Dirty? (fast check; ignores untracked by default for speed/noise)
  # If you want untracked included, change to:
  #   git -C "$path" status --porcelain
  dirty=""
  if ! git -C "$path" diff --quiet --ignore-submodules -- 2>/dev/null; then
    dirty="*"
  elif ! git -C "$path" diff --cached --quiet --ignore-submodules -- 2>/dev/null; then
    dirty="*"
  fi

  out="$repo"
  [ -n "$rel" ] && out="$out:$rel"
  [ -n "$branch" ] && out="$out  $branch$dirty"

  truncate "$out"
  exit 0
fi

# Non-git fallback
base="$(basename "$path")"
parent="$(basename "$(dirname "$path")")"

if [ "$parent" = "/" ] || [ -z "$parent" ]; then
  out="$base"
else
  out="…/$parent/$base"
fi

truncate "$out"
