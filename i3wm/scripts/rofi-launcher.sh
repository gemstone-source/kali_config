#!/usr/bin/env bash
set -u

for custom_launcher in \
    "$HOME/.config/rofi/launchers/type-5/launcher.sh" \
    "$HOME/.config/rofi/launchers/type-3/launcher.sh"; do
    if [[ -x "$custom_launcher" ]]; then
        exec "$custom_launcher"
    fi
done

exec rofi -show drun
