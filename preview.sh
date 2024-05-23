#!/bin/sh

if [ -d "$1" ]; then
    eza --tree --level=2 --icons=always --color=always "$1" | head -200
elif [ -f "$1" ]; then
    bat -n --color=always --line-range :500 "$1"
else
    echo "Unsupported file type"
fi