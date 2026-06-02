#!/bin/bash

OS=$(uname)

ESC=$'\e'
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
REV="${ESC}[7m"
DIM="${ESC}[2m"

hide_cursor() { printf '%s' "${ESC}[?25l"; }
show_cursor() { printf '%s' "${ESC}[?25h"; }

trap 'show_cursor' EXIT

MENU_RESULT=0
SELECTED_MAC=""

# ---- Bluetooth backend (OS-specific) ----------------------------------------
# Each backend exposes:
#   bt_powered            -> exit 0 if controller is on
#   bt_power_on / bt_power_off
#   bt_devices <filter>   -> prints "MAC<TAB>Name" lines (filter: Paired|Connected)
#   bt_scan <seconds>     -> scans, then prints discovered "MAC<TAB>Name" lines
#   bt_connect / bt_disconnect / bt_pair <MAC>

if [ "$OS" = "Darwin" ]; then
    if ! command -v blueutil >/dev/null 2>&1; then
        printf '\n  blueutil is not installed.\n\n  Install it with:  brew install blueutil\n\n'
        printf '  Press any key to close.'
        IFS= read -rsn1 _
        exit 1
    fi

    parse_blueutil() {
        # Reads blueutil device lines on stdin, emits "MAC<TAB>Name".
        local line mac name
        while IFS= read -r line; do
            mac=${line#address: }; mac=${mac%%,*}
            case "$line" in
                *'name: "'*) name=${line#*name: \"}; name=${name%%\"*} ;;
                *) name=$mac ;;
            esac
            [ -n "$mac" ] && printf '%s\t%s\n' "$mac" "$name"
        done
    }

    bt_powered() { [ "$(blueutil --power 2>/dev/null)" = "1" ]; }
    bt_power_on() { blueutil --power 1 2>/dev/null; }
    bt_power_off() { blueutil --power 0 2>/dev/null; }

    bt_devices() {
        local flag=--paired
        [ "$1" = "Connected" ] && flag=--connected
        blueutil "$flag" 2>/dev/null | parse_blueutil
    }

    bt_scan() {
        local dur="$1" tmp pid
        tmp=$(mktemp)
        blueutil --inquiry "$dur" >"$tmp" 2>/dev/null &
        pid=$!
        for ((i=dur; i>0; i--)); do
            printf "\r  Scanning... %ds " "$i"
            sleep 1
        done
        wait "$pid" 2>/dev/null
        parse_blueutil <"$tmp" | awk -F'\t' '!seen[$1]++'
        rm -f "$tmp"
    }

    bt_connect() { blueutil --connect "$1" 2>/dev/null; }
    bt_disconnect() { blueutil --disconnect "$1" 2>/dev/null; }
    bt_pair() { blueutil --pair "$1" 2>/dev/null; }
else
    if ! command -v bluetoothctl >/dev/null 2>&1; then
        printf '\n  bluetoothctl is not installed.\n\n  Press any key to close.'
        IFS= read -rsn1 _
        exit 1
    fi

    bt_powered() { bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; }
    bt_power_on() { bluetoothctl power on >/dev/null 2>&1; }
    bt_power_off() { bluetoothctl power off >/dev/null 2>&1; }

    bt_devices() {
        bluetoothctl devices "$1" 2>/dev/null | grep "^Device " | while read -r _ mac rest; do
            printf '%s\t%s\n' "$mac" "$rest"
        done
    }

    bt_scan() {
        local dur="$1" pid
        bluetoothctl scan on >/dev/null 2>&1 &
        pid=$!
        for ((i=dur; i>0; i--)); do
            printf "\r  Scanning... %ds " "$i"
            sleep 1
        done
        kill "$pid" 2>/dev/null
        bluetoothctl scan off >/dev/null 2>&1
        bt_devices ""
    }

    bt_connect() { bluetoothctl connect "$1" >/dev/null 2>&1; }
    bt_disconnect() { bluetoothctl disconnect "$1" >/dev/null 2>&1; }
    bt_pair() { bluetoothctl pair "$1" >/dev/null 2>&1; }
fi

# ---- UI ---------------------------------------------------------------------
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
    raw_lines=$(bt_devices "$filter")

    if [ -z "$raw_lines" ]; then
        show_message "No devices found." 2
        return 1
    fi

    local -a names=() macs=()
    while IFS=$'\t' read -r mac name; do
        macs+=("$mac")
        names+=("$name")
    done <<< "$raw_lines"

    run_menu "$title" "${names[@]}" || return 1
    SELECTED_MAC="${macs[$MENU_RESULT]}"
}

toggle_power() {
    if bt_powered; then
        bt_power_off
        show_message "Bluetooth disabled."
    else
        bt_power_on
        show_message "Bluetooth enabled."
    fi
}

connect_device() {
    select_device Paired "Connect to device" || return
    printf '\033[2J\033[H'
    printf "\n  Connecting...\n"
    bt_connect "$SELECTED_MAC"
    sleep 2
}

disconnect_device() {
    select_device Connected "Disconnect device" || return
    printf '\033[2J\033[H'
    printf "\n  Disconnecting...\n"
    bt_disconnect "$SELECTED_MAC"
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
    local raw_lines
    raw_lines=$(bt_scan 8)
    printf "\r  Scan complete.        \n"
    show_cursor

    if [ -z "$raw_lines" ]; then
        show_message "No devices found." 2
        return
    fi

    local -a names=() macs=()
    while IFS=$'\t' read -r mac name; do
        macs+=("$mac")
        names+=("$name")
    done <<< "$raw_lines"

    run_menu "Pair device" "${names[@]}" || return
    local mac="${macs[$MENU_RESULT]}"
    printf '\033[2J\033[H'
    printf "\n  Pairing...\n"
    bt_pair "$mac"
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
