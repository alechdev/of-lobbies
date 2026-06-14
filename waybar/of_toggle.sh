#!/bin/bash
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/of-lobbies"
MODE_FILE="$STATE_DIR/mode"
STATUS_FILE="$STATE_DIR/status.json"
MODES=(off teams special individual)
WAYBAR_SIGNAL=9

mkdir -p "$STATE_DIR"

write_off_status() {
    printf '%s\n' \
        '{"text":"󰞍","class":"of-off","tooltip":"OpenFront: off\nClick to cycle: teams -> special -> individual"}' \
        >"$STATUS_FILE"
}

write_loading_status() {
    local mode="$1"
    case "$mode" in
        teams)
            printf '%s\n' \
                '{"text":"󰞍 T loading","class":"of-loading of-teams","tooltip":"OpenFront: teams (loading…)"}' \
                >"$STATUS_FILE"
            ;;
        special)
            printf '%s\n' \
                '{"text":"󰞍 S loading","class":"of-loading of-special","tooltip":"OpenFront: special (loading…)"}' \
                >"$STATUS_FILE"
            ;;
        individual)
            printf '%s\n' \
                '{"text":"󰞍 I loading","class":"of-loading of-individual","tooltip":"OpenFront: individual (loading…)"}' \
                >"$STATUS_FILE"
            ;;
    esac
}

write_status_for_mode() {
    local mode="$1"
    if [[ "$mode" == "off" ]]; then
        write_off_status
    else
        write_loading_status "$mode"
    fi
}

refresh_waybar() {
    pkill "-RTMIN+${WAYBAR_SIGNAL}" waybar >/dev/null 2>&1 || true
}

notify_daemon() {
    if systemctl --user is-active --quiet of-lobbies.service 2>/dev/null; then
        systemctl --user reload of-lobbies.service >/dev/null 2>&1 && return 0
        pid=$(systemctl --user show of-lobbies.service -p MainPID --value 2>/dev/null || true)
        if [[ -n "$pid" && "$pid" != "0" ]]; then
            kill -USR1 "$pid" 2>/dev/null && return 0
        fi
    fi
    systemctl --user enable --now of-lobbies.service >/dev/null 2>&1 || true
}

current="off"
[[ -f "$MODE_FILE" ]] && current=$(<"$MODE_FILE")

next="teams"
for i in "${!MODES[@]}"; do
    if [[ "${MODES[$i]}" == "$current" ]]; then
        next="${MODES[$(( (i + 1) % ${#MODES[@]} ))]}"
        break
    fi
done

printf '%s\n' "$next" >"$MODE_FILE"
write_status_for_mode "$next"
refresh_waybar
notify_daemon
refresh_waybar
