#!/usr/bin/env bash
set -u

custom_powermenu="$HOME/.config/rofi/powermenu/type-1/powermenu.sh"

if [[ -x "$custom_powermenu" ]]; then
    exec "$custom_powermenu"
fi

confirm() {
    [[ "$(printf '%s\n' No Yes | rofi -dmenu -p "Confirm $1")" == Yes ]]
}

case "$(printf '%s\n' Lock Suspend Logout Reboot Shutdown | rofi -dmenu -p Power)" in
    Lock)
        exec i3lock
        ;;
    Suspend)
        confirm Suspend && systemctl suspend
        ;;
    Logout)
        confirm Logout && i3-msg exit
        ;;
    Reboot)
        confirm Reboot && systemctl reboot
        ;;
    Shutdown)
        confirm Shutdown && systemctl poweroff
        ;;
esac
