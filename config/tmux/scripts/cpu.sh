#!/usr/bin/env sh
# Prints CPU usage as a percentage (e.g. "23%")
# Correct on macOS + Linux (explicit %idle parsing)

set -eu

# --- Linux: mpstat (robust) -----------------------------------------------
if command -v mpstat >/dev/null 2>&1; then
  idle="$(
    mpstat 1 1 2>/dev/null | awk '
      BEGIN { idle_col = -1 }
      /^Average:/ {
        if (idle_col >= 0) {
          print $idle_col
        }
      }
      /^CPU/ {
        for (i=1; i<=NF; i++) {
          if ($i == "%idle") idle_col = i
        }
      }
    '
  )"

  if [ -n "${idle:-}" ]; then
    awk -v idle="$idle" 'BEGIN { printf "%.0f%%", (100 - idle) }'
    exit 0
  fi
fi

# --- Linux fallback: /proc/stat -------------------------------------------
if [ -r /proc/stat ]; then
  read_cpu() {
    awk 'NR==1 && $1=="cpu" {
      print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11
    }' /proc/stat
  }

  set -- $(read_cpu)
  u1=$1 n1=$2 s1=$3 i1=$4 io1=$5 ir1=$6 so1=$7 st1=$8 gu1=$9 gn1=${10:-0}
  t1=$((u1+n1+s1+i1+io1+ir1+so1+st1+gu1+gn1))
  id1=$((i1+io1))

  sleep 0.25

  set -- $(read_cpu)
  u2=$1 n2=$2 s2=$3 i2=$4 io2=$5 ir2=$6 so2=$7 st2=$8 gu2=$9 gn2=${10:-0}
  t2=$((u2+n2+s2+i2+io2+ir2+so2+st2+gu2+gn2))
  id2=$((i2+io2))

  dt=$((t2-t1))
  did=$((id2-id1))

  if [ "$dt" -gt 0 ]; then
    awk -v dt="$dt" -v did="$did" \
      'BEGIN { printf "%.0f%%", (dt-did)*100/dt }'
    exit 0
  fi
fi

# --- macOS fallback: top ---------------------------------------------------
if command -v top >/dev/null 2>&1; then
  top -l 1 2>/dev/null | awk '
    /CPU usage:/ {
      gsub(/%|,/, "", $0)
      for (i=1;i<=NF;i++) {
        if ($i=="user") user=$(i-1)
        if ($i=="sys")  sys=$(i-1)
      }
      if (user!="" || sys!="") {
        printf "%.0f%%", (user+sys)
        exit
      }
    }
  '
  exit 0
fi

printf "N/A"
