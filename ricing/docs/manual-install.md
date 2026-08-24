# Manual Kali Hyprland Rice Installation

This guide recreates this repository's Omarchy-style desktop on **Kali Linux
Rolling** without using `setup.sh`. Every important file location is shown, and
the configuration files are included so the setup can be reproduced manually.

The guide assumes:

- Kali Rolling is already installed.
- You have a normal user with `sudo` access.
- You are installing inside VMware or on hardware that can run Wayland.
- The repository is available locally or can be cloned from its Git remote.

The result is:

- Hyprland as the Wayland window manager.
- Quickshell as the top bar and static wallpaper layer.
- Foot, Wofi, Dunst, Neovim, and Zsh as the main desktop tools.
- Fixed workspace rules for terminals, browsers, file managers, editors, and Burp Suite.
- A single `rice` theme command that regenerates application colors.

## 1. Update Kali

Open a terminal in your existing desktop and update the package index first:

```bash
sudo apt update
sudo apt full-upgrade -y
```

Restart if the upgrade installed a new kernel or major system libraries:

```bash
sudo reboot
```

After logging back in, install the tools needed to follow this guide. `curl`
and `ca-certificates` are included here because they are needed to download the
Nerd Font even though they are not desktop components:

```bash
sudo apt install -y \
    sudo git curl ca-certificates unzip fontconfig \
    xz-utils \
    dbus-bin xdg-utils xwayland
```

## 2. Install Hyprland and Desktop Packages

Install the core Wayland session, compositor helpers, and portals:

```bash
sudo apt install -y \
    hyprland \
    hyprland-guiutils \
    quickshell \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    polkitd \
    hyprpolkitagent \
    waybar
```

Install VMware integration so the guest display follows host window and
fullscreen changes:

```bash
sudo apt install -y open-vm-tools open-vm-tools-desktop
```

Install the terminal, shell, launcher, notifications, and editor:

```bash
sudo apt install -y \
    foot \
    zsh \
    starship \
    fzf \
    fastfetch \
    bat \
    eza \
    zoxide \
    ripgrep \
    fd-find \
    tmux \
    wofi \
    dunst \
    neovim
```

Install wallpaper, screenshot, lock, idle, clipboard, and power-menu tools:

```bash
sudo apt install -y \
    hyprlock \
    hypridle \
    grim \
    slurp \
    flameshot \
    wl-clipboard \
    imagemagick \
    wlogout
```

Install audio and media controls:

```bash
sudo apt install -y \
    pipewire \
    wireplumber \
    playerctl \
    pamixer \
    brightnessctl
```

Install system-tray providers and device helpers:

```bash
sudo apt install -y \
    network-manager-applet \
    udiskie \
    bluez \
    bluez-tools \
    blueman
```

Install the small command-line helpers used by the bar and desktop:

```bash
sudo apt install -y \
    jq \
    qrencode \
    socat \
    inotify-tools \
    whois \
    tesseract-ocr \
    libnotify-bin
```

Install the base fonts and icon theme:

```bash
sudo apt install -y \
    fonts-noto \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    fonts-jetbrains-mono \
    papirus-icon-theme
```

Enable the services used by the desktop where applicable:

```bash
sudo systemctl enable --now bluetooth 2>/dev/null || true
sudo systemctl enable --now NetworkManager 2>/dev/null || true
```

The `|| true` keeps this step harmless on installations where a service is
already managed differently. The tray applets themselves are started by
Hyprland later.

## 3. Install JetBrainsMono Nerd Font

The package version of JetBrains Mono does not provide all Nerd Font icons used
by the bar and terminal. Install the Nerd Font variant in the per-user font
directory:

```bash
mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
tmpdir="$(mktemp -d)"
curl -fL \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip \
    -o "$tmpdir/JetBrainsMono.zip"
unzip -oq "$tmpdir/JetBrainsMono.zip" \
    -d "$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
rm -rf "$tmpdir"
fc-cache -f
```

Confirm that the family is visible:

```bash
fc-list | grep -i "JetBrainsMono.*Nerd Font" | head
```

The QML bar refers to this exact family name:

```text
JetBrainsMono Nerd Font
```

If the command returns nothing, log out and in after checking that the ZIP was
downloaded and extracted successfully.

## 4. Get the Repository

Clone the repository if it is not already present. Replace the placeholder with
the real Git URL:

```bash
cd "$HOME"
git clone <your-repo-url> ricing
cd "$HOME/ricing"
```

If the repository is already present, use its existing path:

```bash
cd /home/hashghost/ricing
```

Save the repository path for the commands below:

```bash
export RICE_ROOT="$PWD"
```

The source tree is organized by responsibility:

```text
ricing/
├── bin/                    helper commands
├── config/hypr/             Hyprland Lua files
├── config/quickshell/       Quickshell QML files
├── config/neovim/           Neovim startup file
├── config/wofi/             Wofi launcher settings
├── config/waybar/           optional Waybar fallback
├── config/flameshot/        screenshot settings
├── templates/               theme-generated file templates
├── themes/                  color palettes
├── wallpapers/anime/        static wallpaper assets
└── docs/                    documentation
```

Hyprland and Quickshell do not search this repository automatically. Their
runtime files must be placed under `~/.config`, and the wallpaper images must be
placed under `~/.local/share/riceshell/wallpapers/anime` because that is the path
used by `Wallpaper.qml`.

## 5. Create the Runtime Directories

Create all directories before installing files:

```bash
mkdir -p \
    "$HOME/.config/hypr" \
    "$HOME/.config/quickshell" \
    "$HOME/.config/nvim" \
    "$HOME/.config/wofi" \
    "$HOME/.config/waybar" \
    "$HOME/.config/flameshot" \
    "$HOME/.config/dunst" \
    "$HOME/.config/foot" \
    "$HOME/.config/fastfetch" \
    "$HOME/.config/nvim/lua" \
    "$HOME/.local/bin" \
    "$HOME/.local/share/riceshell/wallpapers/anime"
```

This guide uses symbolic links for the repository-owned files. A symlink means
that an edit in the repository is immediately visible to the running desktop.
If you want standalone copies instead, replace `ln -sf` with `cp -f`.

## 6. Install the Hyprland Configuration

Hyprland 0.56 supports the Lua configuration API used here. The main file is
`~/.config/hypr/hyprland.lua`; its `require` calls load the other Lua modules
from the same directory.

Link the seven repository-owned Hyprland files:

```bash
for file in \
    hyprland.lua \
    monitors.lua \
    looknfeel.lua \
    input.lua \
    bindings.lua \
    autostart.lua \
    windowrules.lua
do
    ln -sf "$RICE_ROOT/config/hypr/$file" "$HOME/.config/hypr/$file"
done
```

### `~/.config/hypr/hyprland.lua`

This establishes the Wayland environment and imports each module. The optional
`theme.lua` file is generated later by the theme command.

```lua
-- Hyprland main config -- Omarchy-style rice for Kali
-- Sources split config files; theme.lua is generated by `rice theme set`.

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("GDK_BACKEND", "wayland,x11")

require("monitors")
require("looknfeel")
require("input")
require("bindings")
require("windowrules")
require("autostart")

-- theme.lua is generated by `rice theme set`; it is optional before the first run.
pcall(require, "theme")
```

### `~/.config/hypr/monitors.lua`

The empty output name means preferred mode and automatic placement. Replace it
with explicit output rules if you have multiple displays.

```lua
-- Monitor setup -- edit to match your displays.
-- The first rule is a sensible auto-detection default.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Examples (uncomment and edit):
-- hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1 })
-- hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@144", position = "1920x0", scale = 1 })

-- Persistent workspaces 1-10 (created at startup)
hl.workspace_rule({ workspace = "1", default = true })
for i = 2, 10 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end
```

Find output names with:

```bash
hyprctl monitors
```

### `~/.config/hypr/looknfeel.lua`

This controls gaps, borders, blur, shadows, layout, and animations. The actual
border colors are added by the generated `theme.lua` file.

```lua
-- Look & feel: gaps, borders, blur, shadows, animations.

hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 12,
        border_size = 2,
        layout = "dwindle",
        resize_on_border = true,
        hover_icon_on_border = true,
        allow_tearing = false,
    },

    decoration = {
        rounding = 10,
        active_opacity = 1.0,
        inactive_opacity = 0.94,
        blur = {
            enabled = true,
            size = 4,
            passes = 2,
            new_optimizations = true,
            ignore_opacity = true,
            xray = false,
        },
        shadow = {
            enabled = true,
            range = 12,
            render_power = 3,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
        force_split = 0,
        smart_split = false,
        smart_resizing = true,
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        background_color = "#000000",
    },

    debug = {
        vfr = true,
    },
})

-- Animations
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows",    enabled = true, speed = 4, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 6, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "default" })
```

### `~/.config/hypr/input.lua`

The software cursor setting is intentional for VMware compatibility. VMware can
expose multiple USB and PS/2 pointer devices. If you are on physical hardware,
you can test `no_hardware_cursors = 0`, but keep the current value if the cursor
becomes invisible or duplicated.

```lua
-- Input devices: keyboard, mouse, touchpad, and cursor.

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "caps:escape",
        kb_rules = "",

        follow_mouse = 1,
        mouse_refocus = false,
        sensitivity = 0,
        accel_profile = "flat",

        repeat_rate = 50,
        repeat_delay = 300,

        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            drag_lock = 0,
            disable_while_typing = true,
            scroll_factor = 0.5,
        },
    },

    cursor = {
        -- Force software cursor rendering for VMware compatibility.
        no_hardware_cursors = 1,
    },
})
```

### `~/.config/hypr/autostart.lua`

This starts idle handling, notifications, tray providers, policykit, and the
Quickshell bar. The Quickshell process uses software rendering because VMware
often fails with the hardware Qt Quick renderer.

```lua
-- Autostart (runs once when Hyprland starts).

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dunst")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("udiskie -t")
    hl.exec_cmd("hyprpolkitagent")
    hl.exec_cmd("env QT_QUICK_BACKEND=software QT_QPA_PLATFORMTHEME=gtk3 quickshell")
    -- VMware's user agent handles display resize events after host fullscreen changes.
    hl.exec_cmd("if command -v vmware-user-suid-wrapper >/dev/null 2>&1; then vmware-user-suid-wrapper; fi")
end)
```

### `~/.config/hypr/windowrules.lua`

Hyprland matches the window class, not the application name shown in the
launcher. Use `hyprctl clients` to discover a class that is not listed here.

```lua
-- App -> workspace pinning (Omarchy-style workflow)
--
-- Hyprland 0.56 Lua rule syntax:
--   hl.window_rule({ match = { class = "regex" }, workspace = "N" })
--
-- Find a window's exact class by running:  hyprctl clients
--
--   workspace 1: terminals
--   workspace 2: browsers
--   workspace 3: file managers
--   workspace 4: notes, code editors, obsidian
--   workspace 5: burpsuite

-- --- Workspace 1: terminals ---
hl.window_rule({ match = { class = "^(foot|alacritty|kitty|wezterm|gnome-terminal-server)$" }, workspace = "1" })

-- --- Workspace 2: browsers ---
-- Firefox on Kali is usually installed as Firefox ESR, whose class is
-- `firefox-esr` rather than `firefox`.
hl.window_rule({ match = { class = "^(firefox|firefox-esr|firefox-developer-edition|firefox-nightly|chromium|chromium-browser|google-chrome|google-chrome-beta|google-chrome-unstable|brave-browser|brave-browser-nightly|librewolf|microsoft-edge|microsoft-edge-dev|vivaldi|vivaldi-stable|opera|opera-developer|waterfox|floorp|zen|qutebrowser|thorium-browser)$" }, workspace = "2" })

-- --- Workspace 3: file managers ---
hl.window_rule({ match = { class = "^(org.gnome.Nautilus|thunar|pcmanfm|nemo)$" }, workspace = "3" })

-- --- Workspace 4: notes, editors, obsidian ---
hl.window_rule({ match = { class = "^(obsidian|code|code-oss|code-url-handler|codium|sublime_text|gedit)$" }, workspace = "4" })

-- --- Workspace 5: burpsuite ---
hl.window_rule({ match = { class = "^(burpsuite|BurpSuiteCommunity|BurpSuiteProfessional|burp)$" }, workspace = "5" })
```

### `~/.config/hypr/bindings.lua`

The Super key is the Windows key. The resize submap starts with `SUPER+R` and
ends with `Escape`.

```lua
-- Keybindings.

local mod = "SUPER"
local term = "foot"
local menu = "wofi --show drun"
local browser = "xdg-open"

-- --- Launch ---
hl.bind(mod .. " + return", hl.dsp.exec_cmd(term))
hl.bind(mod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + E", hl.dsp.exec_cmd("wlogout"))
hl.bind(mod .. " + escape", hl.dsp.exec_cmd("pkill -x wofi || hyprlock"))
hl.bind(mod .. " + S", hl.dsp.exec_cmd("flameshot gui"))
hl.bind("print", hl.dsp.exec_cmd("flameshot gui"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + N", hl.dsp.exec_cmd("dunstctl close-all"))

-- --- Window actions ---
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + M", hl.dsp.exit())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind(mod .. " + T", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + C", hl.dsp.group.toggle())
hl.bind(mod .. " + G", hl.dsp.exec_cmd("hyprctl reload"))

-- --- Focus (vim + arrows) ---
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))

-- --- Move (vim + arrows) ---
hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- --- Resize (hold $mod+R, then use vim/arrows, Esc to finish) ---
hl.bind(mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
    hl.bind("L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
    hl.bind("K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
    hl.bind("J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
    hl.bind("left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
    hl.bind("right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
    hl.bind("up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
    hl.bind("down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- --- Workspaces ---
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- --- Mouse ---
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- --- Media / brightness keys ---
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +10%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), { locked = true, repeating = true })
```

## 7. Install the Quickshell Bar

Quickshell loads `~/.config/quickshell/shell.qml`. The root file creates a
wallpaper layer and one bar per monitor. The other QML files are imported by
`Bar.qml` or instantiated by the root scope.

Link the QML files:

```bash
for file in \
    shell.qml \
    Wallpaper.qml \
    Bar.qml \
    Workspaces.qml \
    ActiveWindow.qml \
    Clock.qml \
    Media.qml \
    Stats.qml \
    Tray.qml
do
    ln -sf "$RICE_ROOT/config/quickshell/$file" "$HOME/.config/quickshell/$file"
done
```

The color object `Colors.qml` is generated in Section 10 and must exist before
the bar starts.

### `~/.config/quickshell/shell.qml`

```qml
//@ pragma UseQApplication
import Quickshell

Scope {
    Wallpaper {}
    Bar {}
}
```

### `~/.config/quickshell/Bar.qml`

```qml
import Quickshell
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 36

            Rectangle {
                anchors.fill: parent
                color: Colors.bgAlt
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 8

                Workspaces {
                    screen: modelData
                }

                ActiveWindow {
                    Layout.fillWidth: true
                }

                Media {}
                Tray { panel: bar }
                Stats {}
                Clock {}
            }
        }
    }
}
```

### `~/.config/quickshell/Wallpaper.qml`

The images are static. The timer changes the file every 300000 milliseconds,
which is five minutes.

```qml
import Quickshell
import Quickshell.Wayland
import QtQuick

// Static anime wallpaper rotation. The image changes every five minutes;
// there are no moving effects or video playback.
Scope {
    id: root

    property int index: 0
    property string wallpaperRoot: Quickshell.env("HOME") + "/.local/share/riceshell/wallpapers/anime/"
    property var wallpapers: [
        "naruto-akatsuki.jpg",
        "sakamoto-days.png",
        "one-punch-man.png",
        "solo-leveling.png",
        "arcane.png"
    ]

    Timer {
        interval: 300000
        repeat: true
        running: true
        onTriggered: root.index = (root.index + 1) % root.wallpapers.length
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "rice-anime-wallpaper"
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "#080808"

            Image {
                anchors.fill: parent
                source: root.wallpaperRoot + root.wallpapers[root.index]
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
            }
        }
    }
}
```

### `~/.config/quickshell/Workspaces.qml`

Only workspaces containing a window are shown. The focused workspace uses the
theme accent color.

```qml
import Quickshell
import Quickshell.Hyprland
import QtQuick

Row {
    id: root
    required property var screen
    readonly property var monitor: Hyprland.monitorFor(screen)
    spacing: 6

    Repeater {
        model: Hyprland.workspaces
        Rectangle {
            required property var modelData
            readonly property var ws: modelData
            visible: root.monitor && ws.monitor && ws.monitor.id === root.monitor.id && ws.toplevels.values.length > 0

            width: 22
            height: 22
            radius: 6
            color: ws.focused ? Colors.accent : Colors.bg
            border.width: 1
            border.color: ws.focused ? Colors.accent : (ws.active ? Colors.accent : Colors.border)

            Text {
                anchors.centerIn: parent
                text: ws.id > 0 ? ws.id.toString() : ws.name
                color: ws.focused ? Colors.accentFg : (ws.active ? Colors.fg : Colors.fgDim)
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                font.bold: ws.focused
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: ws.activate()
            }
        }
    }
}
```

### `~/.config/quickshell/ActiveWindow.qml`

The title is refreshed once per second using Hyprland's JSON client output.

```qml
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Text {
    id: root
    color: Colors.fg
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 13
    horizontalAlignment: Text.AlignHCenter
    elide: Text.ElideRight
    Layout.fillWidth: true

    property string _text: ""

    text: _text

    Process {
        id: proc
        command: ["sh", "-c", "hyprctl activewindow -j 2>/dev/null | jq -r '.title // empty'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root._text = this.text.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }
}
```

### `~/.config/quickshell/Media.qml`

The media widget remains hidden until `playerctl` returns a title.

```qml
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Text {
    id: root
    color: Colors.fgDim
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 13
    Layout.rightMargin: 16
    visible: _text !== ""

    property string _text: ""

    text: _text

    Process {
        id: proc
        command: ["playerctl", "metadata", "--format", "{{ artist }} - {{ title }}"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root._text = this.text.trim()
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }
}
```

### `~/.config/quickshell/Stats.qml`

This calls `~/.local/bin/rice-stats`, installed in Section 9.

```qml
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Text {
    id: root
    color: Colors.fgDim
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 13
    Layout.rightMargin: 16

    property string _text: ""

    text: _text

    Process {
        id: proc
        command: ["sh", "-c", "~/.local/bin/rice-stats"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root._text = this.text.trim()
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }
}
```

### `~/.config/quickshell/Clock.qml`

```qml
import Quickshell
import QtQuick

Text {
    color: Colors.fgDim
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 13
    text: Qt.formatDateTime(clock.date, "ddd MMM d  hh:mm")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
```

### `~/.config/quickshell/Tray.qml`

The Network and `udiskie` entries are hidden to keep the bar compact. The
services still run, and all other tray entries remain clickable.

```qml
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Row {
    id: root
    spacing: 10
    Layout.rightMargin: 16

    required property var panel

    function hideItem(item) {
        const title = String(item.title || "").toLowerCase()
        const icon = String(item.icon || "").toLowerCase()
        return title === "network" || title === "udiskie" ||
            icon === "drive-removable-media-usb-panel"
    }

    Repeater {
        model: SystemTray.items
        WrapperMouseArea {
            required property var modelData
            visible: !root.hideItem(modelData)
            implicitWidth: visible ? 22 : 0
            implicitHeight: visible ? 22 : 0
            margin: 2
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

            IconImage {
                source: modelData.icon
                implicitWidth: 18
                implicitHeight: 18
            }

            onClicked: function(event) {
                if (event.button === Qt.LeftButton) {
                    modelData.activate()
                } else if (event.button === Qt.MiddleButton) {
                    modelData.secondaryActivate()
                } else if (event.button === Qt.RightButton) {
                    const pos = mapToItem(root.panel.contentItem, event.x, event.y)
                    modelData.display(root.panel, Math.round(pos.x), Math.round(pos.y))
                }
            }

            onWheel: function(event) {
                modelData.scroll(event.angleDelta.y, false)
            }
        }
    }
}
```

## 8. Install the Wallpaper Files

Copy the five repository images to the exact path read by `Wallpaper.qml`:

```bash
cp -f "$RICE_ROOT/wallpapers/anime/naruto-akatsuki.jpg" \
    "$HOME/.local/share/riceshell/wallpapers/anime/"
cp -f "$RICE_ROOT/wallpapers/anime/sakamoto-days.png" \
    "$HOME/.local/share/riceshell/wallpapers/anime/"
cp -f "$RICE_ROOT/wallpapers/anime/one-punch-man.png" \
    "$HOME/.local/share/riceshell/wallpapers/anime/"
cp -f "$RICE_ROOT/wallpapers/anime/solo-leveling.png" \
    "$HOME/.local/share/riceshell/wallpapers/anime/"
cp -f "$RICE_ROOT/wallpapers/anime/arcane.png" \
    "$HOME/.local/share/riceshell/wallpapers/anime/"
```

The wallpaper source pages are recorded in
`wallpapers/anime/SOURCES.md`:

- Naruto / Akatsuki: <https://wallhaven.cc/w/o3wpq7>
- Sakamoto Days: <https://wallhaven.cc/w/qz6zmq>
- One-Punch Man: <https://wallhaven.cc/w/r25d5w>
- Solo Leveling: <https://wallhaven.cc/w/k893o7>
- Arcane: <https://wallhaven.cc/w/q2pr5r>

The original artists and uploaders retain their rights. Use replacement images
only when you have permission to use them.

## 9. Install the Bar Status Helper

Install the repository scripts into `~/.local/bin`:

```bash
ln -sf "$RICE_ROOT/bin/rice" "$HOME/.local/bin/rice"
ln -sf "$RICE_ROOT/bin/rice-stats" "$HOME/.local/bin/rice-stats"
chmod +x "$RICE_ROOT/bin/rice" "$RICE_ROOT/bin/rice-stats"
```

Ensure the directory is on your shell's command path:

```bash
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.profile" ;;
esac
export PATH="$HOME/.local/bin:$PATH"
```

`rice-stats` prints CPU usage, RAM usage, and the IPv4 address. It prefers
`tun0` when a VPN is up and otherwise checks `eth0`. On a system using another
interface name, edit `bin/rice-stats` and change the fallback interface.

## 10. Configure the Theme Engine

The theme engine uses one palette file and renders application-specific files.
Copy the source templates and themes into a stable per-user directory by
leaving them in the cloned repository. The `rice` script finds them relative to
its own location, so the symlink from Section 9 must point into this repository.

The default palette is `themes/gemstone/colors.toml`:

```toml
[colors]
# Midnight violet - the default "gemstone" theme
bg = "0e0e16"
bg_alt = "15151f"
fg = "e2e2ea"
fg_dim = "6c6c85"
border = "2a2a3d"
accent = "a78bfa"
accent_fg = "0e0e16"

black = "1a1a2a"
red = "ff6b6b"
green = "9ff28b"
yellow = "f4d97c"
blue = "7aa2f7"
magenta = "c792ea"
cyan = "7de8e8"
white = "e2e2ea"

brblack = "34344a"
brred = "ff8a8a"
brgreen = "b5ffa3"
bryellow = "ffe08a"
brblue = "8ab4ff"
brmagenta = "d8a8ff"
brcyan = "99ffff"
brwhite = "ffffff"
```

Run the first render:

```bash
rice theme set gemstone
```

This creates the following runtime files:

```text
~/.config/foot/foot.ini
~/.config/nvim/lua/theme.lua
~/.config/dunst/dunstrc
~/.config/wofi/style.css
~/.config/quickshell/Colors.qml
~/.config/starship.toml
~/.config/fastfetch/config.jsonc
~/.config/hypr/theme.lua
~/.config/hypr/hyprlock.conf
~/.config/waybar/style.css
~/.config/riceshell/theme
```

The source templates are the complete configuration definitions for these
generated files. They contain placeholders such as `@bg@`; `rice theme set`
replaces those placeholders with values from the selected `colors.toml`.

### `templates/quickshell-colors.qml`

If you are reproducing the configuration outside this repository, save this as
`~/.config/quickshell/Colors.qml` after replacing every placeholder with a
palette value:

```qml
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    readonly property color bg: "#@bg@"
    readonly property color bgAlt: "#@bg_alt@"
    readonly property color fg: "#@fg@"
    readonly property color fgDim: "#@fg_dim@"
    readonly property color border: "#@border@"
    readonly property color accent: "#@accent@"
    readonly property color accentFg: "#@accent_fg@"
    readonly property color red: "#@red@"
    readonly property color green: "#@green@"
    readonly property color yellow: "#@yellow@"
    readonly property color blue: "#@blue@"
    readonly property color magenta: "#@magenta@"
    readonly property color cyan: "#@cyan@"
    readonly property color black: "#@black@"
    readonly property color white: "#@white@"
    readonly property color brRed: "#@brred@"
    readonly property color brGreen: "#@brgreen@"
    readonly property color brYellow: "#@bryellow@"
    readonly property color brBlue: "#@brblue@"
    readonly property color brMagenta: "#@brmagenta@"
    readonly property color brCyan: "#@brcyan@"
}
```

For the `gemstone` palette, for example, `bg` becomes `#0e0e16` and `accent`
becomes `#a78bfa`. Running the command is safer than replacing these manually.

### `templates/hyprland-theme.lua`

The generated `~/.config/hypr/theme.lua` is:

```lua
hl.config({
    general = {
        col = {
            active_border = "rgba(@accent@ee)",
            inactive_border = "rgba(@border@ee)",
        },
    },
    group = {
        col = {
            border_active = "rgba(@accent@ee)",
            border_inactive = "rgba(@border@66)",
        },
    },
})
```

The placeholders are replaced with six-digit palette values, producing valid
Hyprland Lua such as `rgba(a78bfaee)`.

### `templates/foot.ini`

```ini
[main]
font=JetBrainsMono Nerd Font:size=11
pad=8x8
bold-text-in-bright=no

[colors-dark]
background=@bg@
foreground=@fg@
regular0=@black@
regular1=@red@
regular2=@green@
regular3=@yellow@
regular4=@blue@
regular5=@magenta@
regular6=@cyan@
regular7=@white@
bright0=@brblack@
bright1=@brred@
bright2=@brgreen@
bright3=@bryellow@
bright4=@brblue@
bright5=@brmagenta@
bright6=@brcyan@
bright7=@brwhite@
selection-foreground=@accent_fg@
selection-background=@accent@
cursor=@bg@ @fg@
```

### `templates/wofi-style.css`

```css
window {
    margin: 8px;
    border: 2px solid #@border@;
    border-radius: 12px;
    background-color: #@bg@;
}

#input {
    margin: 12px;
    border: 2px solid #@border@;
    border-radius: 8px;
    background-color: #@bg_alt@;
    color: #@fg@;
}

#inner-box {
    margin: 8px;
}

#outer-box {
    margin: 0px;
    border: none;
    background-color: transparent;
}

#scroll {
    margin: 0px;
}

#text {
    margin: 6px;
    color: #@fg@;
}

#entry:selected {
    background-color: #@accent@;
    border-radius: 8px;
}

#entry:selected #text {
    color: #@accent_fg@;
}

#img {
    margin-right: 6px;
}
```

### `templates/dunstrc`

```ini
[global]
    font = JetBrainsMono Nerd Font 11
    origin = top-right
    offset = 10x10
    corner_radius = 10
    frame_color = "#@border@"
    background = "#@bg_alt@"
    foreground = "#@fg@"
    frame_width = 2
    padding = 12
    horizontal_padding = 12
    max_icon_size = 48
    separator_color = frame
    icon_position = left
    format = "<b>%s</b>\n%b"
    word_wrap = yes

[urgency_low]
    background = "#@bg_alt@"
    foreground = "#@fg_dim@"
    timeout = 4

[urgency_normal]
    background = "#@bg_alt@"
    foreground = "#@fg@"
    timeout = 6

[urgency_critical]
    background = "#@red@"
    foreground = "#@accent_fg@"
    timeout = 0

[shortcuts]
    close = ctrl+space
    close_all = ctrl+shift+space
    history = ctrl+grave
```

### `templates/starship.toml`

```toml
palette = "riceshell"

[palettes.riceshell]
bg = "#@bg@"
fg = "#@fg@"
accent = "#@accent@"
red = "#@red@"
green = "#@green@"
yellow = "#@yellow@"
blue = "#@blue@"
magenta = "#@magenta@"
cyan = "#@cyan@"

[directory]
style = "bold accent"
truncation_length = 3

[git_branch]
style = "magenta"

[git_status]
style = "green"

[character]
success_symbol = "[❯](bold accent)"
error_symbol = "[❯](bold red)"
```

### `templates/fastfetch.jsonc`

```jsonc
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "type": "auto",
        "color": {
            "1": "#@accent@",
            "2": "#@magenta@",
            "3": "#@cyan@"
        }
    },
    "display": {
        "separator": "  "
    },
    "modules": [
        { "type": "title", "key": "  " },
        { "type": "os" },
        { "type": "kernel" },
        { "type": "uptime" },
        { "type": "packages" },
        { "type": "shell" },
        { "type": "wm" },
        { "type": "terminal" },
        { "type": "cpu" },
        { "type": "gpu" },
        { "type": "memory" },
        { "type": "disk" }
    ]
}
```

### `templates/hyprlock.conf`

```ini
background {
    color = rgba(@bg@ff)
}

input-field {
    size = 220, 50
    outline_thickness = 2
    dots_size = 0.2
    dots_spacing = 0.2
    outer_color = rgba(@accent@ff)
    inner_color = rgba(@bg_alt@ff)
    font_color = rgba(@fg@ff)
    placeholder_text = password
    rounding = 10
    position = 0, 20
    halign = center
    valign = center
}

label {
    text = cmd[update:1000] date +"%H:%M"
    color = rgba(@fg@ff)
    font_size = 48
    position = 0, -80
    halign = center
    valign = center
}
```

### `templates/waybar-style.css`

Waybar is a fallback bar. Quickshell is the bar started by the main config.

```css
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrainsMono Nerd Font";
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background: #@bg_alt@;
    color: #@fg@;
}

#workspaces button {
    color: #@fg_dim@;
    padding: 0 6px;
}

#workspaces button.active {
    color: #@accent_fg@;
    background: #@accent@;
}

#workspaces button.urgent {
    color: #@red@;
}

#clock,
#battery,
#network,
#pulseaudio,
#window {
    padding: 0 10px;
    color: #@fg@;
}

#pulseaudio.muted {
    color: #@red@;
}
```

### `templates/neovim-theme.lua`

The generated file is loaded by `~/.config/nvim/init.lua`:

```lua
local c = {
    bg = "#@bg@",
    bg_alt = "#@bg_alt@",
    fg = "#@fg@",
    fg_dim = "#@fg_dim@",
    border = "#@border@",
    accent = "#@accent@",
    accent_fg = "#@accent_fg@",
    red = "#@red@",
    green = "#@green@",
    yellow = "#@yellow@",
    blue = "#@blue@",
    magenta = "#@magenta@",
    cyan = "#@cyan@",
    black = "#@black@",
    white = "#@white@",
}

vim.g.colors_name = "@theme@"

local function hi(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

hi("Normal", { fg = c.fg, bg = c.bg })
hi("CursorLine", { bg = c.bg_alt })
hi("CursorLineNr", { fg = c.accent })
hi("LineNr", { fg = c.fg_dim })
hi("Comment", { fg = c.fg_dim, italic = true })
hi("Statement", { fg = c.magenta })
hi("Keyword", { fg = c.magenta })
hi("Function", { fg = c.blue })
hi("String", { fg = c.green })
hi("Number", { fg = c.yellow })
hi("Constant", { fg = c.yellow })
hi("Type", { fg = c.cyan })
hi("Identifier", { fg = c.fg })
hi("Boolean", { fg = c.red })
hi("Special", { fg = c.cyan })
hi("PreProc", { fg = c.magenta })
hi("Operator", { fg = c.fg })
hi("Visual", { bg = c.border })
hi("Search", { fg = c.accent_fg, bg = c.accent })
hi("IncSearch", { fg = c.accent_fg, bg = c.accent })
hi("StatusLine", { fg = c.fg, bg = c.bg_alt })
hi("StatusLineNC", { fg = c.fg_dim, bg = c.bg_alt })
hi("VertSplit", { fg = c.border })
hi("Pmenu", { bg = c.bg_alt })
hi("PmenuSel", { fg = c.accent_fg, bg = c.accent })
hi("DiagnosticError", { fg = c.red })
hi("DiagnosticWarn", { fg = c.yellow })
hi("DiagnosticInfo", { fg = c.blue })
hi("DiagnosticHint", { fg = c.cyan })
```

## 11. Install Neovim, Wofi, Flameshot, and Waybar Configs

Link the repository-owned files:

```bash
ln -sf "$RICE_ROOT/config/neovim/init.lua" \
    "$HOME/.config/nvim/init.lua"
ln -sf "$RICE_ROOT/config/wofi/config" \
    "$HOME/.config/wofi/config"
ln -sf "$RICE_ROOT/config/waybar/config.jsonc" \
    "$HOME/.config/waybar/config.jsonc"
ln -sf "$RICE_ROOT/config/flameshot/flameshot.ini" \
    "$HOME/.config/flameshot/flameshot.ini"
```

### `~/.config/nvim/init.lua`

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.scrolloff = 8
vim.opt.showmode = false
vim.opt.laststatus = 2

require("theme")
```

### `~/.config/wofi/config`

```ini
width=600
height=380
prompt=❯
mode=drun
allow_markup=true
allow_images=false
insensitive=true
term=foot
```

The generated `~/.config/wofi/style.css` comes from
`templates/wofi-style.css` above.

### `~/.config/flameshot/flameshot.ini`

```ini
[General]
showStartupLaunchMessage=false
```

For Wayland capture, use the Grim adapter in Flameshot's settings if the
installed version exposes that option. The keybindings call `flameshot gui`.
The separate `grim` and `slurp` packages are retained as command-line fallback
tools.

### `~/.config/waybar/config.jsonc`

```jsonc
{
    "layer": "top",
    "position": "top",
    "height": 34,
    "spacing": 8,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["hyprland/window"],
    "modules-right": ["pulseaudio", "network", "battery", "clock"],
    "hyprland/workspaces": {
        "format": "{name}",
        "on-click": "activate"
    },
    "hyprland/window": {
        "max-length": 60
    },
    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": "MUTED",
        "on-click": "pamixer -t"
    },
    "network": {
        "format-wifi": "{signalStrength}%",
        "format-disconnected": "offline",
        "on-click": "nm-connection-editor"
    },
    "battery": {
        "format": "{capacity}%",
        "format-charging": "{capacity}% ⚡"
    },
    "clock": {
        "format": "{:%a %b %d  %H:%M}"
    }
}
```

## 12. Configure Zsh and Starship

Make Zsh the login shell:

```bash
chsh -s "$(command -v zsh)"
```

Log out and in after changing the shell. Add Starship and the optional command
helpers to `~/.zshrc`:

```bash
cat >> "$HOME/.zshrc" <<'EOF'

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
[[ -r /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -r /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
alias ls='eza --icons'
alias cat='batcat'
EOF
```

The theme command creates `~/.config/starship.toml`. Start a new terminal or
reload the shell:

```bash
exec zsh
```

## 13. Start the Hyprland Session

Check the configuration before logging into it:

```bash
hyprland --verify-config
```

If it reports `config ok`, log out of the current desktop. At the login screen,
open the session selector and choose **Hyprland**, then log in.

The first Hyprland start runs the following processes from `autostart.lua`:

| Process | Purpose |
|---|---|
| `hypridle` | idle and lock integration |
| `dunst` | notifications |
| `nm-applet` | NetworkManager tray provider |
| `blueman-applet` | Bluetooth tray provider |
| `udiskie -t` | removable-drive tray provider |
| `hyprpolkitagent` | graphical privilege prompts |
| `quickshell` | bar and wallpaper |

## 14. Verify Each Component

Run these commands from a terminal inside Hyprland:

```bash
hyprctl monitors
hyprctl workspaces
hyprctl clients
hyprctl activewindow
```

Check the helper and theme commands:

```bash
~/.local/bin/rice-stats
rice theme list
rice theme current
```

The expected theme list contains:

```text
catppuccin-mocha
```

Run Quickshell directly when debugging QML:

```bash
pkill -x quickshell || true
```

Press `Ctrl+C` after reading any errors. Restart it in the background afterward:

```bash
env QT_QUICK_BACKEND=software QT_QPA_PLATFORMTHEME=gtk3 quickshell >/tmp/quickshell.log 2>&1 &
```

Test the expected workflow:

1. Press `SUPER+Return`; Foot should open on workspace 1.
2. Press `SUPER+D`; Wofi should open.
3. Open Firefox ESR; it should move to workspace 2.
4. Press `SUPER+S`; Flameshot should start a capture.
5. Press `SUPER+Escape`; Hyprlock should start.
6. Start media playback; the title should appear in the bar.
7. Wait five minutes; the wallpaper should change.

## 15. Keybindings

| Keys | Action |
|---|---|
| `SUPER + Return` | Foot terminal |
| `SUPER + D` | Wofi application launcher |
| `SUPER + B` | Open the default browser |
| `SUPER + E` | Wlogout power menu |
| `SUPER + Escape` | Wofi toggle, then Hyprlock |
| `SUPER + S` or `Print` | Flameshot screenshot |
| `SUPER + H/J/K/L` | Focus left/down/up/right |
| `SUPER + Shift + H/J/K/L` | Move the active window |
| `SUPER + R`, then arrows or `H/J/K/L` | Resize the active window |
| `SUPER + 1..9` | Focus workspace 1..9 |
| `SUPER + 0` | Focus workspace 10 |
| `SUPER + Shift + 1..0` | Move window to workspace |
| `SUPER + Q` | Close active window |
| `SUPER + V` | Toggle floating |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + G` | Reload Hyprland |
| `SUPER + P` | Play or pause media |
| `SUPER + N` | Close all notifications |

## 16. Change Themes

Four palettes are included:

```bash
rice theme list
rice theme current
rice theme set gemstone
rice theme set tokyo-night
rice theme set catppuccin-mocha
rice theme set everforest
```

After changing a theme, reload Hyprland and restart Quickshell so every running
component reads its generated file:

```bash
hyprctl reload
pkill -x quickshell || true
```

Create a custom palette from the default:

```bash
cp -r "$RICE_ROOT/themes/gemstone" "$RICE_ROOT/themes/my-theme"
${EDITOR:-nano} "$RICE_ROOT/themes/my-theme/colors.toml"
rice theme set my-theme
```

Palette values are six hexadecimal digits without a leading `#`. The required
keys are `bg`, `bg_alt`, `fg`, `fg_dim`, `border`, `accent`, `accent_fg`, the
eight normal ANSI colors, and the eight bright ANSI colors.

## 17. Customize the Layout

Edit the repository source file, not only the generated destination, when a
file is symlinked:

```bash
${EDITOR:-nano} "$RICE_ROOT/config/hypr/bindings.lua"
${EDITOR:-nano} "$RICE_ROOT/config/hypr/windowrules.lua"
${EDITOR:-nano} "$RICE_ROOT/config/hypr/monitors.lua"
${EDITOR:-nano} "$RICE_ROOT/config/quickshell/Bar.qml"
```

Apply Hyprland changes without logging out:

```bash
hyprctl reload
```

For a new workspace rule, first find the actual class:

```bash
hyprctl clients
```

Then add a rule such as:

```lua
hl.window_rule({ match = { class = "^(my-app)$" }, workspace = "6" })
```

If you replace wallpapers, preserve the five names used by `Wallpaper.qml`, or
edit the `wallpapers` list in that file and restart Quickshell.

## 18. VMware Troubleshooting

### Quickshell crashes or the bar is absent

Run Quickshell with software rendering:

```bash
command -v vmware-user-suid-wrapper
vmware-user-suid-wrapper
```

The same agent is started automatically by `autostart.lua`; it is required for
VMware to deliver display resize events when the host enters or leaves
fullscreen.

### The pointer is invisible or duplicated

The current input config forces software cursor rendering:

```lua
cursor = {
    no_hardware_cursors = 1,
},
```

If VMware still exposes duplicate pointers, shut down the VM and inspect its
hardware settings. Remove duplicate PS/2 mouse devices while keeping one
virtual USB mouse device. Do not add arbitrary `hl.device(...)` disable rules
unless you have confirmed the exact device name with:

```bash
hyprctl devices
```

### The bar has no icons

The Qt GTK platform theme and Papirus icon package are important:

```bash
sudo apt install -y papirus-icon-theme xdg-desktop-portal-gtk
hyprctl reload
```

The environment variable is set in `hyprland.lua` and when Quickshell starts:

```text
QT_QPA_PLATFORMTHEME=gtk3
```

### The bar has no CPU, RAM, or IP text

```bash
ls -l "$HOME/.local/bin/rice-stats"
"$HOME/.local/bin/rice-stats"
```

If the IP is not shown, check the interface names:

```bash
ip -4 -o addr
```

Edit the fallback interface in `bin/rice-stats` if Kali uses something other
than `eth0`.

### Hyprland starts to a black screen

Check that the Hyprland session was selected at the login screen and inspect
the boot log:

```bash
journalctl -b0 -t hyprland
```

From another TTY, verify that the config is readable:

```bash
hyprland --verify-config
```

## 19. Useful References

- Hyprland: <https://hyprland.org/> and <https://wiki.hyprland.org/>
- Hyprland Lua configuration: <https://wiki.hyprland.org/Configuring/Configuring-Hyprland/>
- Quickshell: <https://quickshell.org/> and <https://quickshell.org/docs/v0.3.0/guide/>
- Foot: <https://codeberg.org/dnkl/foot>
- Wofi: <https://hg.sr.ht/~scoopta/wofi>
- Dunst: <https://dunst-project.org/>
- Neovim: <https://neovim.io/>
- Hyprlock: <https://github.com/hyprwm/hyprlock>
- Hypridle: <https://github.com/hyprwm/hypridle>
- Hyprpolkitagent: <https://github.com/hyprwm/hyprpolkitagent>
- Starship: <https://starship.rs/>
- Fastfetch: <https://github.com/fastfetch-cli/fastfetch>
- Nerd Fonts: <https://www.nerdfonts.com/>
- Waybar: <https://github.com/Alexays/Waybar>
- Wlogout: <https://github.com/ArtsyMacaw/wlogout>
- Omarchy inspiration: <https://github.com/basecamp/omarchy>

## 20. Optional Shortcut

This guide intentionally does not depend on `setup.sh`. After understanding the
file layout and manual steps, the script can be used as a convenience on a
fresh Kali installation:

```bash
cd "$RICE_ROOT"
./setup.sh
```

The manual commands above are the authoritative explanation of what each part
of the setup does and where every runtime file belongs.
