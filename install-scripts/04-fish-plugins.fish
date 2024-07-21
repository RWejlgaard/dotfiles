#!/usr/bin/env fish

# tide
fisher install IlanCosman/tide

# setup tide
tide configure \
    --auto \
    --style=Lean \
    --prompt_colors='True color' \
    --show_time='24-hour format' \
    --lean_prompt_height='One line' \
    --prompt_spacing=Compact \
    --icons='Few icons' \
    --transient=No
