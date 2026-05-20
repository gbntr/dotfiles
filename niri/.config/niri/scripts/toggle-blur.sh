#!/bin/bash
CONFIG_FILE="$HOME/.config/niri/dms/blur.kdl"
if grep -q "blur true" "$CONFIG_FILE"; then
    sed -i 's/blur true/blur false/' "$CONFIG_FILE"
    notify-send "Niri" "Blur desativado" -i dialogue-information
else
    sed -i 's/blur false/blur true/' "$CONFIG_FILE"
    notify-send "Niri" "Blur ativado" -i dialogue-information
fi
niri msg action reload-config
