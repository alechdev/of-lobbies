#!/bin/bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"

install -d "$HOME/.local/bin"
install -d "$HOME/.config/waybar/scripts"
install -d "$HOME/.config/systemd/user"

ln -sf "$REPO/bin/of-lobbies" "$HOME/.local/bin/of-lobbies"
ln -sf "$REPO/bin/of-lobbies-daemon" "$HOME/.local/bin/of-lobbies-daemon"
ln -sf "$REPO/waybar/of_status.sh" "$HOME/.config/waybar/scripts/of_status.sh"
ln -sf "$REPO/waybar/of_toggle.sh" "$HOME/.config/waybar/scripts/of_toggle.sh"
ln -sf "$REPO/systemd/of-lobbies.service" "$HOME/.config/systemd/user/of-lobbies.service"

systemctl --user daemon-reload

echo "Installed of-lobbies from $REPO"
