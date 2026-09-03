#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

sudo apt-get update
sudo apt-get install -y \
    alacritty arandr brightnessctl dex i3 i3blocks i3lock lxappearance \
    flameshot network-manager-gnome picom playerctl polybar rofi thunar variety \
    wireplumber pipewire-bin xss-lock

install -d "$HOME/.config/i3" "$HOME/.config/polybar" "$HOME/.config/alacritty" "$HOME/.config/gtk-3.0" "$HOME/.local/bin"
install -m 644 "$SCRIPT_DIR/i3/config" "$HOME/.config/i3/config"
install -m 644 "$SCRIPT_DIR/i3/i3blocks.conf" "$HOME/.config/i3/i3blocks.conf"
install -m 644 "$SCRIPT_DIR/polybar/config.ini" "$HOME/.config/polybar/config.ini"
install -m 755 "$SCRIPT_DIR/polybar/launch.sh" "$HOME/.config/polybar/launch.sh"
install -m 644 "$SCRIPT_DIR/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
install -d "$HOME/.config/picom"
install -m 644 "$SCRIPT_DIR/picom/picom.conf" "$HOME/.config/picom/picom.conf"
install -m 755 "$SCRIPT_DIR/scripts/rofi-launcher.sh" "$HOME/.local/bin/kali-rofi-launcher"
install -m 755 "$SCRIPT_DIR/scripts/powermenu.sh" "$HOME/.local/bin/kali-rofi-powermenu"
install -m 755 "$SCRIPT_DIR/scripts/flameshot-x11.sh" "$HOME/.local/bin/kali-flameshot"
install -m 644 "$SCRIPT_DIR/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
install -m 644 "$SCRIPT_DIR/gtk-3.0/bookmarks" "$HOME/.config/gtk-3.0/bookmarks"
install -d "$HOME/.config/i3/pictures"
install -m 644 "$SCRIPT_DIR/pictures"/* "$HOME/.config/i3/pictures/"

# Keep IBus available for input methods without placing its layout indicator in
# Polybar's system tray.
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.freedesktop.ibus.panel show-icon-on-systray false || true
fi

install -m 644 "$REPO_ROOT/.vimrc" "$HOME/.vimrc"
install -m 644 "$REPO_ROOT/.zshrc" "$HOME/.zshrc"

# The Rofi theme directory is intentionally ignored by this repository because
# it contains a separately maintained upstream theme collection.
if [[ -x "$SCRIPT_DIR/rofi/setup.sh" ]]; then
    (
        cd "$SCRIPT_DIR/rofi"
        ./setup.sh
    )
    if [[ -f "$HOME/.config/rofi/config.rasi" ]]; then
        mv "$HOME/.config/rofi/config.rasi" "$HOME/.config/rofi/config"
    fi
else
    printf '%s\n' 'Rofi theme files are not present; using the packaged Rofi configuration.' >&2
fi

printf '%s\n' 'i3 configuration installed. Select i3 at the login screen or restart the session.'
