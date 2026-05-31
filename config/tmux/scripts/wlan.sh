#!/bin/bash
if rfkill list wifi 2>/dev/null | grep -q "Soft blocked: yes\|Hard blocked: yes"; then
    echo "WLAN: #[fg=colour1]OFF#[fg=colour7]"
else
    echo "WLAN: #[fg=colour2]ON#[fg=colour7]"
fi
