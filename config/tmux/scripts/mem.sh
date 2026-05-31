#!/bin/bash
percent=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{print int((t-a)*100/t)}' /proc/meminfo)
if [ "$percent" -ge 85 ]; then
    colour=colour1
elif [ "$percent" -ge 60 ]; then
    colour=colour3
else
    colour=colour2
fi

echo "RAM: #[fg=$colour]${percent}%#[fg=colour7]"
