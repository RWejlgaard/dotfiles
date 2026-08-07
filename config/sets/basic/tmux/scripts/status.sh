#!/bin/bash

CONFIG="${BASH_SOURCE%/*}/status.conf"

OS=$(uname)

gadget_wlan() {
    if [ "$OS" = "Darwin" ]; then
        local dev
        dev=$(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi/{getline; print $2; exit}')
        [ -z "$dev" ] && dev=en0
        if networksetup -getairportpower "$dev" 2>/dev/null | grep -q ": On"; then
            echo "WLAN: #[fg=colour2]ON#[fg=colour7]"
        else
            echo "WLAN: #[fg=colour1]OFF#[fg=colour7]"
        fi
        return
    fi
    if rfkill list wifi 2>/dev/null | grep -q "Soft blocked: yes\|Hard blocked: yes"; then
        echo "WLAN: #[fg=colour1]OFF#[fg=colour7]"
    else
        echo "WLAN: #[fg=colour2]ON#[fg=colour7]"
    fi
}

gadget_bluetooth() {
    if [ "$OS" = "Darwin" ]; then
        local state
        state=$(system_profiler SPBluetoothDataType 2>/dev/null | awk '/State:/{print $2; exit}')
        [ -z "$state" ] && return
        if [ "$state" = "On" ]; then
            echo "BT: #[fg=colour2]ON#[fg=colour7]"
        else
            echo "BT: #[fg=colour1]OFF#[fg=colour7]"
        fi
        return
    fi
    rfkill list bluetooth 2>/dev/null | grep -q . || return
    if rfkill list bluetooth 2>/dev/null | grep -q "Soft blocked: yes\|Hard blocked: yes"; then
        echo "BT: #[fg=colour1]OFF#[fg=colour7]"
    else
        echo "BT: #[fg=colour2]ON#[fg=colour7]"
    fi
}

gadget_battery() {
    if [ "$OS" = "Darwin" ]; then
        # ioreg reports a usable TimeRemaining (minutes) even when pmset
        # still says "(no estimate)" shortly after un/plugging.
        local data cur max remain percent fmt
        data=$(ioreg -rn AppleSmartBattery 2>/dev/null)
        [ -z "$data" ] && return
        cur=$(echo "$data" | awk -F' = ' '/"AppleRawCurrentCapacity"/{print $2; exit}')
        max=$(echo "$data" | awk -F' = ' '/"AppleRawMaxCapacity"/{print $2; exit}')
        remain=$(echo "$data" | awk -F' = ' '/"TimeRemaining"/{print $2; exit}')
        { [ -z "$cur" ] || [ -z "$max" ] || [ "$max" -eq 0 ] 2>/dev/null; } && return
        percent=$(( cur * 100 / max ))
        [ "$percent" -le 20 ] && colour=colour1 || { [ "$percent" -le 50 ] && colour=colour3 || colour=colour2; }
        # 65535 is the sentinel for "not yet calculated".
        if [ -n "$remain" ] && [ "$remain" -gt 0 ] 2>/dev/null && [ "$remain" -lt 65535 ] 2>/dev/null; then
            local h m
            h=$(( remain / 60 ))
            m=$(( remain % 60 ))
            [ "$h" -gt 0 ] && fmt="${h}h ${m}m" || fmt="${m}m"
            echo "BAT: #[fg=$colour]${percent}%#[fg=colour7] - ${fmt}"
        else
            echo "BAT: #[fg=$colour]${percent}%#[fg=colour7]"
        fi
        return
    fi
    output=$(acpi -b 2>/dev/null | grep -v -i "unavailable" | head -1)
    [ -z "$output" ] && return
    percent=$(echo "$output" | grep -oP '\d+(?=%)')
    time=$(echo "$output" | grep -oP '\d+:\d+:\d+')
    [ "$percent" -le 20 ] && colour=colour1 || { [ "$percent" -le 50 ] && colour=colour3 || colour=colour2; }
    if [ -n "$time" ]; then
        h=$(echo "$time" | cut -d: -f1 | sed 's/^0//')
        m=$(echo "$time" | cut -d: -f2 | sed 's/^0//')
        [ -z "$h" ] && h=0
        [ -z "$m" ] && m=0
        [ "$h" -gt 0 ] && fmt="${h}h ${m}m" || fmt="${m}m"
        echo "BAT: #[fg=$colour]${percent}%#[fg=colour7] - ${fmt}"
    else
        echo "BAT: #[fg=$colour]${percent}%#[fg=colour7]"
    fi
}

gadget_cpu() {
    if [ "$OS" = "Darwin" ]; then
        local idle percent
        idle=$(top -l 1 -n 0 2>/dev/null | awk '/CPU usage/{for(i=1;i<=NF;i++) if($i=="idle"){gsub(/%/,"",$(i-1)); print $(i-1)}}')
        [ -z "$idle" ] && return
        percent=$(printf '%.0f' "$(echo "100 - $idle" | bc -l 2>/dev/null)")
        [ -z "$percent" ] && return
        [ "$percent" -ge 80 ] && colour=colour1 || { [ "$percent" -ge 50 ] && colour=colour3 || colour=colour2; }
        echo "CPU: #[fg=$colour]${percent}%#[fg=colour7]"
        return
    fi
    read_stat() { awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8, $5}' /proc/stat; }
    s1=$(read_stat); sleep 0.5; s2=$(read_stat)
    total=$(($(echo "$s2"|cut -d' ' -f1) - $(echo "$s1"|cut -d' ' -f1)))
    idle=$(($(echo "$s2"|cut -d' ' -f2) - $(echo "$s1"|cut -d' ' -f2)))
    percent=$(( (total - idle) * 100 / total ))
    [ "$percent" -ge 80 ] && colour=colour1 || { [ "$percent" -ge 50 ] && colour=colour3 || colour=colour2; }
    echo "CPU: #[fg=$colour]${percent}%#[fg=colour7]"
}

gadget_mem() {
    if [ "$OS" = "Darwin" ]; then
        local free percent
        free=$(memory_pressure 2>/dev/null | awk -F': ' '/free percentage/{gsub(/%/,"",$2); print $2}')
        [ -z "$free" ] && return
        percent=$((100 - free))
        [ "$percent" -ge 85 ] && colour=colour1 || { [ "$percent" -ge 60 ] && colour=colour3 || colour=colour2; }
        echo "RAM: #[fg=$colour]${percent}%#[fg=colour7]"
        return
    fi
    percent=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{print int((t-a)*100/t)}' /proc/meminfo)
    [ "$percent" -ge 85 ] && colour=colour1 || { [ "$percent" -ge 60 ] && colour=colour3 || colour=colour2; }
    echo "RAM: #[fg=$colour]${percent}%#[fg=colour7]"
}

gadget_temp() {
    if [ "$OS" = "Darwin" ]; then
        # No built-in CPU temp sensor on macOS; requires osx-cpu-temp (brew).
        command -v osx-cpu-temp >/dev/null 2>&1 || return
        local temp int
        temp=$(osx-cpu-temp 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)
        [ -z "$temp" ] && return
        int=${temp%.*}
        [ "$int" -ge 80 ] && colour=colour1 || { [ "$int" -ge 60 ] && colour=colour3 || colour=colour2; }
        echo "TEMP: #[fg=$colour]${int}°C#[fg=colour7]"
        return
    fi
    temp=$(sensors k10temp-pci-00c3 2>/dev/null | grep "Tctl" | grep -oP '\d+\.\d+' | head -1)
    [ -z "$temp" ] && return
    int=${temp%.*}
    [ "$int" -ge 80 ] && colour=colour1 || { [ "$int" -ge 60 ] && colour=colour3 || colour=colour2; }
    echo "TEMP: #[fg=$colour]${int}°C#[fg=colour7]"
}

gadget_disk() {
    percent=$(df / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
    [ -z "$percent" ] && return
    [ "$percent" -ge 90 ] && colour=colour1 || { [ "$percent" -ge 70 ] && colour=colour3 || colour=colour2; }
    echo "DSK: #[fg=$colour]${percent}%#[fg=colour7]"
}

parts=()
while IFS= read -r line || [ -n "$line" ]; do
    [[ "$line" =~ ^[[:space:]]*# || -z "${line//[[:space:]]/}" ]] && continue
    fn="gadget_${line}"
    declare -f "$fn" > /dev/null || continue
    result=$("$fn")
    [ -n "$result" ] && parts+=("$result")
done < "$CONFIG"

( IFS='|'; out="${parts[*]}"; printf '%s' "${out//|/ | }" )
