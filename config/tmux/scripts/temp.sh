#!/bin/bash
temp=$(sensors k10temp-pci-00c3 2>/dev/null | grep "Tctl" | grep -oP '\d+\.\d+' | head -1)
[ -z "$temp" ] && exit 0

int=${temp%.*}
if [ "$int" -ge 80 ]; then
    colour=colour1
elif [ "$int" -ge 60 ]; then
    colour=colour3
else
    colour=colour2
fi

echo "CPU: #[fg=$colour]${int}°C#[fg=colour7]"
