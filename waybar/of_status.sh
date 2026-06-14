#!/bin/bash
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/of-lobbies/status.json"

if [[ -f "$STATE" ]]; then
    cat "$STATE"
else
    printf '%s\n' '{"text":"󰞍","class":"of-off","tooltip":"OpenFront: off\nClick to cycle modes"}'
fi
