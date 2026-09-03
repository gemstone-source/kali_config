#!/usr/bin/env bash
# setup.sh — Omarchy-style rice installer for Kali (Debian-based) + Hyprland
set -euo pipefail

RICE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"
FONTS_DIR="$HOME/.local/share/fonts"
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip"

info() { printf '\033[1;34m[rice]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[rice]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[rice]\033[0m %s\n' "$*" >&2; exit 1; }

command -v sudo >/dev/null 2>&1 || die "sudo is required"
command -v git  >/dev/null 2>&1 || die "git is required"

info "updating package lists..."
sudo apt update

info "installing packages..."
mapfile -t PKGS < <(grep -v '^#' "$RICE_ROOT/packages.list" | grep -v '^[[:space:]]*$')
sudo apt install -y "${PKGS[@]}"

if ! fc-list 2>/dev/null | grep -qi "JetBrainsMono.*Nerd Font"; then
  info "installing JetBrainsMono Nerd Font..."
  mkdir -p "$FONTS_DIR"
  tmpdir="$(mktemp -d)"
  curl -fsSL "$NERD_FONT_URL" -o "$tmpdir/font.zip"
  unzip -oq "$tmpdir/font.zip" -d "$FONTS_DIR"
  rm -rf "$tmpdir"
  fc-cache -f
else
  info "nerd font already present"
fi

info "installing rice CLI..."
mkdir -p "$HOME/.local/bin"
ln -sf "$RICE_ROOT/bin/rice" "$HOME/.local/bin/rice"
ln -sf "$RICE_ROOT/bin/rice-stats" "$HOME/.local/bin/rice-stats"

if command -v gcc >/dev/null 2>&1; then
  info "installing VMware Aquamarine EGL workaround..."
  VMWARE_EGL_SHIM="$HOME/.local/lib/libaquamarine-vmware-egl.so"
  mkdir -p "$HOME/.local/lib"
  gcc -shared -fPIC -O2 -Wall -Wextra -Werror \
    "$RICE_ROOT/bin/aquamarine-vmware-egl.c" -ldl -o "$VMWARE_EGL_SHIM"

  mkdir -p "$HOME/.local/share/wayland-sessions"
  printf '%s\n' \
    '[Desktop Entry]' \
    'Name=Hyprland (VMware workaround)' \
    'Comment=Hyprland with the Aquamarine shared-EGL workaround' \
    "Exec=/usr/bin/env LD_PRELOAD=$VMWARE_EGL_SHIM /usr/bin/start-hyprland" \
    'TryExec=/usr/bin/start-hyprland' \
    'Type=Application' \
    > "$HOME/.local/share/wayland-sessions/hyprland-vmware.desktop"
fi

link_file() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    [ "$(readlink "$dst")" = "$src" ] && return 0
    mv "$dst" "$dst.bak.$(date +%s)"
    warn "backed up existing $(basename "$dst")"
  fi
  ln -s "$src" "$dst"
}

info "linking configs..."
link_file "$RICE_ROOT/config/hypr/hyprland.lua"   "$CONFIG/hypr/hyprland.lua"
link_file "$RICE_ROOT/config/hypr/monitors.lua"   "$CONFIG/hypr/monitors.lua"
link_file "$RICE_ROOT/config/hypr/looknfeel.lua"  "$CONFIG/hypr/looknfeel.lua"
link_file "$RICE_ROOT/config/hypr/input.lua"      "$CONFIG/hypr/input.lua"
link_file "$RICE_ROOT/config/hypr/bindings.lua"   "$CONFIG/hypr/bindings.lua"
link_file "$RICE_ROOT/config/hypr/autostart.lua"  "$CONFIG/hypr/autostart.lua"
link_file "$RICE_ROOT/config/hypr/windowrules.lua" "$CONFIG/hypr/windowrules.lua"

for q in shell Wallpaper Bar Workspaces ActiveWindow Clock Media Stats; do
  link_file "$RICE_ROOT/config/quickshell/$q.qml" "$CONFIG/quickshell/$q.qml"
done

info "installing anime wallpapers..."
WALLPAPER_DIR="$HOME/.local/share/riceshell/wallpapers/anime"
mkdir -p "$WALLPAPER_DIR"
rm -f "$WALLPAPER_DIR"/*
cp -f "$RICE_ROOT/wallpapers/anime"/* "$WALLPAPER_DIR/"

link_file "$RICE_ROOT/config/neovim/init.lua"       "$CONFIG/nvim/init.lua"
link_file "$RICE_ROOT/config/wofi/config"           "$CONFIG/wofi/config"
link_file "$RICE_ROOT/config/waybar/config.jsonc"   "$CONFIG/waybar/config.jsonc"
link_file "$RICE_ROOT/config/flameshot/flameshot.ini" "$CONFIG/flameshot/flameshot.ini"

if [ "$(basename "${SHELL:-/bin/sh}")" != "zsh" ]; then
  info "setting default shell to zsh"
  sudo chsh -s "$(command -v zsh)" "$USER"
fi

info "applying default theme (gemstone)..."
"$HOME/.local/bin/rice" theme set gemstone

printf '\n\033[1;32mDone!\033[0m\n'
printf 'Log out, then select "Hyprland" at the login screen.\n'
printf 'Keybinds: SUPER+D launcher, SUPER+Return terminal, SUPER+E power menu, SUPER+Esc lock.\n'
