#!/bin/bash
read_stat() { awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8, $5}' /proc/stat; }

s1=$(read_stat); sleep 0.5; s2=$(read_stat)

total=$(($(echo $s2|cut -d' ' -f1) - $(echo $s1|cut -d' ' -f1)))
idle=$(($(echo $s2|cut -d' ' -f2) - $(echo $s1|cut -d' ' -f2)))
percent=$(( (total - idle) * 100 / total ))

if [ "$percent" -ge 80 ]; then
    colour=colour1
elif [ "$percent" -ge 50 ]; then
    colour=colour3
else
    colour=colour2
fi

echo "CPU: #[fg=$colour]${percent}%#[fg=colour7]"
