#!/usr/bin/env bash
set -u

unset WAYLAND_DISPLAY
export QT_QPA_PLATFORM=xcb

exec /usr/bin/flameshot "$@"
