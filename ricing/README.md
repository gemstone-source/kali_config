# ricing — an Omarchy-style rice for Kali

A beautiful, modern, opinionated desktop rice for **Kali Linux** (Debian-based),
heavily inspired by [DHH's Omarchy](https://github.com/basecamp/omarchy).

It recreates the Omarchy look and workflow on Kali using the same core stack:

| Omarchy | This rice |
|---|---|
| Hyprland (tiling WM) | **Hyprland** (Wayland) |
| Quickshell (top bar) | **Quickshell** top bar |
| foot terminal | **foot** |
| Neovim | **Neovim** (minimal) |
| Theme engine + `omarchy theme set` | **`rice theme set`** (4 curated themes) |
| fzf menus / launcher | **wofi** launcher |

## Features

- **Hyprland** tiling window manager with vim-style keybinds (`SUPER+H/J/K/L`)
- **Quickshell** top bar: workspaces, active-window title, media, system tray,
  CPU/RAM/IP status, clock
- **Static anime wallpapers**: Naruto, Sakamoto Days, One-Punch Man, Solo
  Leveling, and Arcane rotate every five minutes
- **App → workspace pinning**: terminals→1, browsers→2, file managers→3,
  notes/editors/Obsidian→4, Burp Suite→5
- **4 curated themes**: `gemstone` (default), `tokyo-night`, `catppuccin-mocha`, `everforest`
- A small **`rice` CLI** that themes every app at once (foot, nvim, dunst, wofi,
  Quickshell, starship, fastfetch, hyprlock, waybar)
- Notifications (dunst), lockscreen (hyprlock), idle (hypridle), power menu (wlogout),
  screenshots (grim/slurp)

## Requirements

- Kali Rolling (or any Debian testing/unstable derivative)
- A GPU/driver that supports Wayland
- `sudo` access

## Install

```bash
git clone <your-repo-url> ricing
cd ricing
./setup.sh
```

`setup.sh` installs all packages, downloads the JetBrainsMono Nerd Font, copies
the anime wallpaper set, symlinks configs into `~/.config`, and applies the
default `gemstone` theme. It is safe to re-run (it backs up any conflicting
configs).

Then **log out** and select **Hyprland** at the login screen.

## Usage

```bash
rice theme list            # list themes
rice theme current         # show active theme
rice theme set tokyo-night # switch theme (re-themes every app)
rice screenshot            # screenshot -> ~/Pictures/screenshots + clipboard
rice update                # git pull + reapply current theme
```

See [`docs/`](docs/) for the full guide, and
[docs/how-it-was-made.md](docs/how-it-was-made.md) for a beginner-friendly
walkthrough of how this rice was built and how to configure every part of it.
For a complete manual installation without relying on the installer, see
[docs/manual-install.md](docs/manual-install.md).

## Keybinds

| Keys | Action |
|---|---|
| `SUPER + Return` | terminal |
| `SUPER + D` | app launcher (wofi) |
| `SUPER + E` | power menu (wlogout) |
| `SUPER + Esc` | lock (hyprlock) |
| `SUPER + S` | screenshot (flameshot gui) |
| `SUPER + H/J/K/L` | focus window |
| `SUPER + Shift + H/J/K/L` | move window |
| `SUPER + R` then `H/J/K/L` | resize, `Esc` to finish |
| `SUPER + 1..0` | go to workspace 1..10 |
| `SUPER + Shift + 1..0` | move window to workspace |
| `SUPER + Q` | close window |
| `SUPER + V` | toggle float |
| `SUPER + F` | fullscreen |
| `SUPER + P` | play/pause |

## Themes

Themes live in `themes/<name>/colors.toml`. Each theme is a single palette file;
`rice theme set` renders it into every application. To add your own:

```bash
cp -r themes/gemstone themes/my-theme
$EDITOR themes/my-theme/colors.toml
rice theme set my-theme
```

## Repository layout

```
setup.sh                 idempotent installer
packages.list            apt packages (mapped from Omarchy's package list)
config/hypr/             Hyprland config (split files)
config/quickshell/       Quickshell top bar (QML)
config/neovim/           minimal Neovim init
config/wofi/             launcher
config/waybar/           optional Waybar fallback
themes/                  4 theme palettes
templates/               themed-config templates rendered by `rice`
bin/rice                 theme + helper CLI
bin/rice-stats           bar status script (CPU/RAM/IP)
docs/                    guides
```

## References

- [Omarchy](https://github.com/basecamp/omarchy) — the inspiration
- [Hyprland](https://hyprland.org/)
- [Quickshell](https://quickshell.org/)
- [foot](https://codeberg.org/dnkl/foot)
- [wofi](https://hg.sr.ht/~scoopta/wofi)
