#!/bin/bash
percent=$(df / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
[ -z "$percent" ] && exit 0

if [ "$percent" -ge 90 ]; then
    colour=colour1
elif [ "$percent" -ge 70 ]; then
    colour=colour3
else
    colour=colour2
fi

echo "DSK: #[fg=$colour]${percent}%#[fg=colour7]"
