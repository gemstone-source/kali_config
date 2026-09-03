#!/usr/bin/env bash
set -u

config="$HOME/.config/polybar/config.ini"
log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/polybar"

mkdir -p "$log_dir"

# exec_always runs this script again after every i3 reload.
if command -v polybar-msg >/dev/null 2>&1; then
    polybar-msg cmd quit >/dev/null 2>&1 || true
else
    pkill -x polybar >/dev/null 2>&1 || true
fi

for bar in main; do
    polybar -c "$config" "$bar" >"$log_dir/$bar.log" 2>&1 &
done
