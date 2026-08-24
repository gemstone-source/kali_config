# Keybinds

`SUPER` is the Windows/Super key (the "Cmd" key in Omarchy terms).

## Launching

| Keys | Action |
|---|---|
| `SUPER + Return` | terminal (foot) |
| `SUPER + D` | app launcher (wofi) |
| `SUPER + B` | browser (xdg-open) |
| `SUPER + E` | power menu (wlogout) |
| `SUPER + Esc` | lock screen (hyprlock) |
| `SUPER + S` | screenshot (flameshot gui) |
| `PRINT` | screenshot (flameshot gui) |

## Windows

| Keys | Action |
|---|---|
| `SUPER + Q` | close window |
| `SUPER + V` | toggle floating |
| `SUPER + F` | toggle fullscreen |
| `SUPER + T` | toggle split direction |
| `SUPER + P` | play/pause media |
| `SUPER + G` | reload Hyprland |

## Navigation (vim-style)

| Keys | Action |
|---|---|
| `SUPER + H/J/K/L` | focus window (left/down/up/right) |
| `SUPER + Shift + H/J/K/L` | move window |
| `SUPER + arrows` | focus (arrow fallback) |
| `SUPER + Shift + arrows` | move (arrow fallback) |
| `SUPER + R` then `H/J/K/L` | resize (vim) |
| `SUPER + R` then `arrows` | resize (arrows) |
| `SUPER + R` then `Esc` | finish resize |

## Workspaces

| Keys | Action |
|---|---|
| `SUPER + 1..9` | go to workspace 1..9 |
| `SUPER + 0` | go to workspace 10 |
| `SUPER + Shift + 1..0` | move window to workspace |
| `SUPER + mouse wheel` | next/previous workspace |
| `SUPER + drag` (mouse) | move window |
| `SUPER + right-drag` (mouse) | resize window |

## Media keys

Volume, mute, play/pause, next/prev and brightness keys are bound to
`pamixer`, `playerctl` and `brightnessctl`.
