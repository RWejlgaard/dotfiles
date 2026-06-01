#!/bin/bash

ESC=$'\e'
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
REV="${ESC}[7m"
DIM="${ESC}[2m"

hide_cursor() { printf '%s' "${ESC}[?25l"; }
show_cursor() { printf '%s' "${ESC}[?25h"; }

trap 'show_cursor' EXIT

bt_cmd() { bluetoothctl "$@" 2>/dev/null; }
bt_powered() { bt_cmd show | grep -q "Powered: yes"; }

MENU_RESULT=0
SELECTED_MAC=""

run_menu() {
    local title="$1"; shift
    local -a items=("$@")
    local selected=0
    local count=${#items[@]}

    while true; do
        hide_cursor
        printf '\033[2J\033[H'
        printf "\n  ${BOLD}%s${RESET}\n\n" "$title"
        for ((i=0; i<count; i++)); do
            if [ "$i" -eq "$selected" ]; then
                printf "  ${REV}  %-44s  ${RESET}\n" "${items[$i]}"
            else
                printf "  ${DIM}  %-44s  ${RESET}\n" "${items[$i]}"
            fi
        done
        printf "\n  ${DIM}↑↓ navigate   Enter select   q back${RESET}\n"

        IFS= read -rsn1 key
        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 0.1 seq
            case "$seq" in
                '[A') ((selected > 0)) && ((selected--)) ;;
                '[B') ((selected < count - 1)) && ((selected++)) ;;
            esac
        elif [[ "$key" == '' ]]; then
            MENU_RESULT=$selected
            show_cursor
            return 0
        elif [[ "$key" == 'q' || "$key" == 'Q' ]]; then
            show_cursor
            return 1
        fi
    done
}

show_message() {
    printf '\033[2J\033[H'
    printf "\n  %s\n" "$1"
    sleep "${2:-1}"
}

select_device() {
    local filter="$1" title="$2"
    local raw_lines
    raw_lines=$(bt_cmd devices "$filter" | grep "^Device" | sed 's/^Device //')

    if [ -z "$raw_lines" ]; then
        show_message "No devices found." 2
        return 1
    fi

    local -a names=() macs=()
    while IFS= read -r line; do
        macs+=("$(echo "$line" | awk '{print $1}')")
        names+=("$(echo "$line" | cut -d' ' -f2-)")
    done <<< "$raw_lines"

    run_menu "$title" "${names[@]}" || return 1
    SELECTED_MAC="${macs[$MENU_RESULT]}"
}

toggle_power() {
    if bt_powered; then
        bt_cmd power off
        show_message "Bluetooth disabled."
    else
        bt_cmd power on
        show_message "Bluetooth enabled."
    fi
}

connect_device() {
    select_device Paired "Connect to device" || return
    printf '\033[2J\033[H'
    printf "\n  Connecting...\n"
    bt_cmd connect "$SELECTED_MAC"
    sleep 2
}

disconnect_device() {
    select_device Connected "Disconnect device" || return
    printf '\033[2J\033[H'
    printf "\n  Disconnecting...\n"
    bt_cmd disconnect "$SELECTED_MAC"
    sleep 1
}

scan_pair() {
    if ! bt_powered; then
        show_message "Bluetooth is off. Enable it first." 2
        return
    fi

    hide_cursor
    printf '\033[2J\033[H'
    printf "\n"
    bluetoothctl scan on >/dev/null 2>&1 &
    local scan_pid=$!
    for i in $(seq 8 -1 1); do
        printf "\r  Scanning... %ds " "$i"
        sleep 1
    done
    kill "$scan_pid" 2>/dev/null
    bt_cmd scan off >/dev/null 2>&1
    printf "\r  Scan complete.        \n"
    show_cursor

    local raw_lines
    raw_lines=$(bt_cmd devices | grep "^Device" | sed 's/^Device //')
    if [ -z "$raw_lines" ]; then
        show_message "No devices found." 2
        return
    fi

    local -a names=() macs=()
    while IFS= read -r line; do
        macs+=("$(echo "$line" | awk '{print $1}')")
        names+=("$(echo "$line" | cut -d' ' -f2-)")
    done <<< "$raw_lines"

    run_menu "Pair device" "${names[@]}" || return
    local mac="${macs[$MENU_RESULT]}"
    printf '\033[2J\033[H'
    printf "\n  Pairing...\n"
    bt_cmd pair "$mac"
    sleep 3
}

while true; do
    bt_powered && pwr="ON " || pwr="OFF"
    run_menu "Bluetooth" \
        "Power                              [ $pwr ]" \
        "Connect paired device" \
        "Disconnect device" \
        "Scan & pair new device" || exit 0

    case $MENU_RESULT in
        0) toggle_power ;;
        1) connect_device ;;
        2) disconnect_device ;;
        3) scan_pair ;;
    esac
done
