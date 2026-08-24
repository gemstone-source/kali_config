# Kali Rice — Installation & Configuration Guide

A single, start-to-finish guide for installing and configuring this
**Omarchy-style desktop rice** on **Kali Linux**.

This rice ports the look and workflow of [Omarchy](https://github.com/basecamp/omarchy)
(by DHH) onto Kali, using the same core stack: **Hyprland** (tiling window
manager) + **Quickshell** (top bar) + a theme engine that re-themes every app
from a single palette file.

---

## 1. What you're getting

| Piece | What it does |
|---|---|
| **Hyprland** | tiling window manager (Wayland), vim-style keybinds |
| **Quickshell** | top bar: workspaces, window title, media, tray, CPU/RAM/IP, clock |
| **foot** | terminal emulator |
| **Neovim** | text editor (minimal) |
| **wofi** | app launcher |
| **dunst** | notifications |
| **starship** | shell prompt |
| **fastfetch** | system info on terminal open |
| **Quickshell / hyprlock / hypridle** | wallpaper, lock screen, idle |
| **wlogout** | power menu (logout/reboot/shutdown) |
| **`rice`** | theme switcher CLI |
| **`rice-stats`** | bar status script (CPU/RAM/IP) |

Apps are pinned to fixed workspaces:

| Workspace | Opens here |
|---|---|
| 1 | terminals |
| 2 | browsers |
| 3 | file managers |
| 4 | notes / editors / Obsidian |
| 5 | Burp Suite |

Four themes ship with it: `gemstone` (default), `tokyo-night`,
`catppuccin-mocha`, `everforest`.

### Complete tool and font inventory

| Area | Tools and packages used |
|---|---|
| Session and shell | Hyprland 0.56 Lua config, Quickshell 0.3, foot, zsh, starship, fzf, tmux, zoxide, xdg-desktop-portal-hyprland, xdg-desktop-portal-gtk |
| Desktop UI | wofi, dunst, hyprlock, hypridle, hyprpolkitagent, hyprland-guiutils, polkitd, wlogout, Waybar fallback |
| Editing and terminal tools | Neovim, bat, eza, ripgrep, fd-find, fastfetch |
| Screenshots and clipboard | Flameshot, grim, slurp, wl-clipboard, ImageMagick |
| Audio and media | PipeWire, WirePlumber, playerctl, pamixer, brightnessctl |
| Tray and devices | `nm-applet`, `blueman-applet`, BlueZ, udiskie, Quickshell SystemTray |
| Helpers | jq, qrencode, socat, inotify-tools, unzip, whois, tesseract-ocr, libnotify-bin |
| Fonts | JetBrainsMono Nerd Font, Noto fonts, Noto CJK, Noto Color Emoji |
| Icons | Papirus icon theme package; current Qt icon lookup uses `QT_QPA_PLATFORMTHEME=gtk3` and the system Flat-Remix theme |

The JetBrainsMono Nerd Font is used by the terminal and bar at 13px. Noto
fonts provide general and CJK fallback coverage; Noto Color Emoji provides
colored emoji glyphs. The cursor size is set to 24.

Flameshot is configured with `useGrimAdapter=true` for Wayland capture and
`showTrayIcon=true` so it remains available from the tray.

---

## 2. Requirements

- **Kali Linux Rolling** (or any Debian testing/unstable derivative)
- A GPU/driver that supports **Wayland**
- `sudo` access
- `git`

> **Note for VMs:** this works on VMware/VirtualBox, but Quickshell needs
> software rendering there (handled automatically — see section 9).

---

## 3. Quick start

```bash
git clone <your-repo-url> ricing
cd ricing
./setup.sh                 # installs everything (asks for your sudo password)
# log out, then pick "Hyprland" at the login screen
```

That's it. Read on for the detailed walkthrough and how to customize it.

---

## 4. Step 1 — Get the repo

```bash
git clone <your-repo-url> ricing
cd ricing
```

What you'll find inside:

```
setup.sh                 the installer
packages.list            apt packages to install
config/hypr/             Hyprland config (split into small files)
config/quickshell/       top bar (QML)
config/neovim/           minimal Neovim init
config/wofi/             launcher config
config/waybar/           optional Waybar fallback
themes/                  4 theme palettes
templates/               config templates rendered by `rice`
bin/rice                 theme + helper CLI
bin/rice-stats           bar status script
docs/                    more guides
```

---

## 5. Step 2 — Run the installer

```bash
./setup.sh
```

It does five things (all idempotent — safe to re-run):

1. `apt update` + installs every package in `packages.list`
2. downloads and installs **JetBrainsMono Nerd Font**
3. installs `rice` and `rice-stats` into `~/.local/bin`
4. symlinks the configs into `~/.config` (backing up anything that clashes)
5. copies the five anime wallpapers into `~/.local/share/riceshell/wallpapers/anime`
6. applies the default `gemstone` theme

If a config already exists that it doesn't own, it moves it to
`<name>.bak.<timestamp>` instead of overwriting it.

---

## 6. Step 3 — Log into Hyprland

Log out, then at the login screen select **Hyprland** as the session.

---

## 7. Step 4 — Verify it works

Checklist:

```bash
# the config has no errors
hyprland --verify-config

# the bar status script works
~/.local/bin/rice-stats          # -> "CPU ..% · RAM ..% · eth0 <ip>"

# theme CLI works
rice theme list
```

Open a terminal (`SUPER + Return`) and a browser — the browser should appear on
**workspace 2**. Firefox ESR uses the `firefox-esr` window class and is included
alongside Chromium, Chrome, Brave, LibreWolf, Edge, Vivaldi, Opera, Waterfox,
Floorp, Zen, qutebrowser, and Thorium.

Check the top bar shows workspaces on the left, the focused window title in the
center, and CPU/RAM/IP + clock on the right.

Useful diagnostics anytime:

```bash
hyprctl reload        # apply Hyprland config changes live
hyprctl clients       # find an app's class (for window rules)
hyprctl activewindow  # see the focused window
quickshell            # run the bar manually to see QML errors
```

---

## 8. Step 5 — Switch themes

```bash
rice theme list              # list themes
rice theme current           # show the active one
rice theme set tokyo-night   # switch (re-themes every app)
```

`rice theme set` regenerates **everything** from one palette file
(`themes/<name>/colors.toml`): foot, Neovim, dunst, wofi, Quickshell colors,
starship, fastfetch, Hyprland borders, hyprlock, and waybar. The anime wallpaper
images are independent of the color theme.

---

## 9. Step 6 — Make it your own

### Keybinds

Edit `~/.config/hypr/bindings.lua`. The format is:

```lua
hl.bind("SUPER + return", hl.dsp.exec_cmd("foot"))
```

| Part | Meaning |
|---|---|
| `SUPER` | the Windows/Super key |
| `return` | the key |
| `hl.dsp.exec_cmd` | action (run a command) |
| `"foot"` | the command |

Full list in `docs/keybinds.md`.

### Pin apps to workspaces

Edit `~/.config/hypr/windowrules.lua`. Each rule:

```lua
hl.window_rule({ match = { class = "^(obsidian)$" }, workspace = "4" })
```

> **Hyprland 0.56 uses Lua.** The config is now a `.lua` file instead of the
> old `.conf`/hyprlang format. Match on a window's `class` (find it with
> `hyprctl clients`).

### The top bar

Layout is in `~/.config/quickshell/Bar.qml` — the order of
`Workspaces / ActiveWindow / Media / Tray / Stats / Clock` controls left-to-right
ordering. Bar height is `implicitHeight`.

All bar text is consistent: `JetBrainsMono Nerd Font` at 13px; the active-window
title uses `Colors.fg`, everything else on the right uses `Colors.fgDim`.

The right-corner `Stats` (CPU/RAM/IP) reads from `~/.local/bin/rice-stats` —
it shows `eth0`'s IP, or `tun0` when a VPN is up. Edit `bin/rice-stats` in the
repo to change interface names or add fields.

The tray uses Quickshell's SystemTray service. Flameshot and other tray apps
remain visible and clickable while their background providers are running. The
Network and `udiskie` icons are intentionally hidden to keep the bar clean, but
their services remain available; Bluetooth, Flameshot, and future tray providers
are not filtered.

### Wallpaper

The wallpaper is a Quickshell background layer, not a moving animation. The
five images in `wallpapers/anime/` are copied to
`~/.local/share/riceshell/wallpapers/anime/` and rotate every five minutes.
Replace those files to use a different static wallpaper set.

### Make your own theme

```bash
cp -r themes/gemstone themes/mine
nano themes/mine/colors.toml    # values are hex WITHOUT the '#'
rice theme set mine
```

See `docs/themes.md` for every palette key.

### Monitors / multiple screens

Edit `~/.config/hypr/monitors.lua`. Default auto-detects:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
```

Uncomment and edit the examples there for multi-monitor setups.

### Fonts

`setup.sh` installs JetBrainsMono Nerd Font and the package list installs
`fonts-noto`, `fonts-noto-cjk`, and `fonts-noto-color-emoji`. To use a different
primary font, place it in `~/.local/share/fonts`, run `fc-cache -f`, then update the font name in
`templates/foot.ini`, `templates/dunstrc` and `templates/waybar-style.css`, and
re-run `rice theme set`.

### Terminal (foot)

`~/.config/foot/foot.ini` is generated by `rice`. Tweak font size/padding in
`templates/foot.ini`, then `rice theme set $(rice theme current)`.

### Neovim

`~/.config/nvim/init.lua` sets options and loads `lua/theme.lua` (generated).
Edit `templates/neovim-theme.lua` to change highlight groups.

### Shell prompt

`~/.config/starship.toml` (generated). Enable it in `~/.zshrc`:

```bash
eval "$(starship init zsh)"
```

---

## 10. Troubleshooting

### System-tray icons are blank/black

This happens when Qt can't resolve the StatusNotifier icon names (it falls back
to the `hicolor` theme, which lacks them). Fix: make Qt read the system icon
theme via the GTK platform theme. This is already set globally:

```
env = QT_QPA_PLATFORMTHEME,gtk3
```

Then make sure an icon theme is installed (`papirus-icon-theme` is in
`packages.list`) and re-run `hyprctl reload`. Tray apps: `nm-applet` (network),
`blueman-applet` (bluetooth), `udiskie -t` (drives), `flameshot` (with
`showTrayIcon=true`).

### Black screen on login

- Selected the **Hyprland** session? Not the desktop default.
- Check GPU/Wayland support, and logs: `journalctl -b0 -t hyprland`.

### Quickshell bar doesn't appear / crashes

On **VMs without 3D acceleration** (VMware SVGA II etc.) Quickshell crashes with
`invalid arguments for wl_surface.attach`. The installer already launches it with
software rendering:

```
exec-once = env QT_QUICK_BACKEND=software quickshell
```

On real hardware with working GPU drivers you can remove the
`env QT_QUICK_BACKEND=software` part from `~/.config/hypr/autostart.lua`.
Run `quickshell` manually to see QML errors.

### Center of the bar shows nothing

The center title comes from `hyprctl activewindow`. Make sure `jq` is installed
and that `hyprctl activewindow` returns a title. Re-run setup if `jq` is missing.

### Bar shows no CPU/RAM/IP

```bash
ls -l ~/.local/bin/rice-stats
~/.local/bin/rice-stats
```

### Colors didn't change after switching theme

```bash
rice theme set <theme>
hyprctl reload
```

### Font looks wrong / missing glyphs

Run `fc-cache -f` and log out/in.

### Known package differences vs. Omarchy

| Omarchy | On Kali |
|---|---|
| `rofi-wayland` | `wofi` |
| `mako` | `dunst` |
| `policykit-1-gnome` | `hyprpolkitagent` |
| `fonts-noto-emoji` | `fonts-noto-color-emoji` |

---

## 11. Uninstall

```bash
rm -rf ~/.config/hypr ~/.config/quickshell ~/.config/nvim \
       ~/.config/foot ~/.config/wofi ~/.config/dunst ~/.config/waybar \
       ~/.config/starship.toml ~/.config/fastfetch ~/.config/riceshell \
       ~/.local/share/riceshell ~/.local/bin/rice ~/.local/bin/rice-stats
sudo apt autoremove --purge hyprland quickshell   # optional
```

---

## 12. References

- [Omarchy](https://github.com/basecamp/omarchy) — the inspiration
- [Hyprland](https://hyprland.org/) · [wiki](https://wiki.hyprland.org/)
- [Quickshell](https://quickshell.org/) · [docs](https://quickshell.org/docs/v0.3.0/guide/)
- [foot](https://codeberg.org/dnkl/foot) · [wofi](https://hg.sr.ht/~scoopta/wofi)
- [dunst](https://dunst-project.org/) · [Neovim](https://neovim.io/)
- [hyprlock](https://github.com/hyprwm/hyprlock) · [hypridle](https://github.com/hyprwm/hypridle) · [hyprpolkitagent](https://github.com/hyprwm/hyprpolkitagent)
- [starship](https://starship.rs/) · [fastfetch](https://github.com/fastfetch-cli/fastfetch) · [Nerd Fonts](https://www.nerdfonts.com/)
- [waybar](https://github.com/Alexays/Waybar) · [wlogout](https://github.com/ArtsyMacaw/wlogout)
