#!/usr/bin/env sh
# Prints memory usage as a percentage (e.g. "61%")
# Linux: prefers free; fallback to /proc/meminfo
# macOS: uses vm_stat

set -eu

# Linux: free
if command -v free >/dev/null 2>&1; then
  # Use "available" if present (more accurate than "free")
  free -m 2>/dev/null | awk '
    $1=="Mem:" {
      total=$2
      used=$3
      avail=$7
      if (avail != "" && total > 0) {
        # used = total - available
        printf "%.0f%%", ( (total-avail) * 100 / total )
      } else if (total > 0) {
        printf "%.0f%%", ( used * 100 / total )
      }
      exit
    }
  '
  exit 0
fi

# Linux fallback: /proc/meminfo
if [ -r /proc/meminfo ]; then
  awk '
    BEGIN { total=0; avail=0; free=0; buffers=0; cached=0; }
    $1=="MemTotal:" { total=$2 }
    $1=="MemAvailable:" { avail=$2 }
    $1=="MemFree:" { free=$2 }
    $1=="Buffers:" { buffers=$2 }
    $1=="Cached:" { cached=$2 }
    END {
      if (total<=0) { print "N/A"; exit }
      if (avail>0) {
        used = total - avail
      } else {
        # approximate if MemAvailable missing (older kernels)
        used = total - (free + buffers + cached)
      }
      if (used < 0) used = 0
      printf "%.0f%%", (used * 100 / total)
    }
  ' /proc/meminfo
  exit 0
fi

# macOS: vm_stat
if command -v vm_stat >/dev/null 2>&1; then
  # vm_stat outputs counts of pages; page size is usually 4096 bytes.
  # We'll compute: used = active + wired + compressed (if present)
  # total = used + free
  vm_stat 2>/dev/null | awk '
    BEGIN {
      pagesize=4096
      free=0; active=0; wired=0; compressed=0; speculative=0; inactive=0;
    }
    /page size of/ {
      # e.g. "Mach Virtual Memory Statistics: (page size of 4096 bytes)"
      for (i=1;i<=NF;i++) if ($i ~ /^[0-9]+$/) pagesize=$i
    }
    /Pages free:/        { gsub("\\.","",$3); free=$3 }
    /Pages active:/      { gsub("\\.","",$3); active=$3 }
    /Pages inactive:/    { gsub("\\.","",$3); inactive=$3 }
    /Pages speculative:/ { gsub("\\.","",$3); speculative=$3 }
    /Pages wired down:/  { gsub("\\.","",$4); wired=$4 }
    /Pages occupied by compressor:/ { gsub("\\.","",$5); compressed=$5 }
    END {
      used = active + wired + compressed
      total = used + free
      if (total <= 0) { print "N/A"; exit }
      printf "%.0f%%", (used * 100 / total)
    }
  '
  exit 0
fi

printf "N/A"
