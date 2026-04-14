#!/bin/bash
grim -g "$(slurp)" - | wl-copy
if [ $? -eq 0 ]; then
    notify-send -u normal "Screenshot" "Copiado para a área de transferência" -i camera-photo
fi
