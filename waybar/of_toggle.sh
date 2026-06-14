#!/bin/bash
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/of-lobbies"
MODE_FILE="$STATE_DIR/mode"
MODES=(off teams special individual)

mkdir -p "$STATE_DIR"

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

systemctl --user enable --now of-lobbies.service >/dev/null 2>&1 || true
systemctl --user daemon-reload >/dev/null 2>&1 || true
systemctl --user reload of-lobbies.service >/dev/null 2>&1 \
    || pkill -USR1 -x of-lobbies-daemon >/dev/null 2>&1 \
    || systemctl --user restart of-lobbies.service >/dev/null 2>&1 || true
