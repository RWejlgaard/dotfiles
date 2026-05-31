#!/bin/bash
output=$(acpi -b 2>/dev/null | grep -v -i "unavailable" | head -1)
[ -z "$output" ] && exit 0

percent=$(echo "$output" | grep -oP '\d+(?=%)')
time=$(echo "$output" | grep -oP '\d+:\d+:\d+')

if [ -n "$time" ]; then
    h=$(echo "$time" | cut -d: -f1 | sed 's/^0//')
    m=$(echo "$time" | cut -d: -f2 | sed 's/^0//')
    [ -z "$h" ] && h=0
    [ -z "$m" ] && m=0
    if [ "$h" -gt 0 ]; then
        fmt="${h}h ${m}m"
    else
        fmt="${m}m"
    fi
    echo "BAT: ${percent}% - ${fmt}"
else
    echo "BAT: ${percent}%"
fi
