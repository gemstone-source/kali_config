# i3 window manager

This directory contains the i3, Polybar, GTK, and optional Rofi configuration
used by this repository. It is intended for Debian-family systems and is
tested on Kali Linux.

## Installation

Run the installer from any directory:

```sh
git clone https://github.com/gemstone-source/kali_config.git
cd kali_config/i3wm
chmod +x setup.sh
./setup.sh
```

The installer detects its own location, installs the required packages, and
copies the configuration to `~/.config`. It also installs Rofi wrapper commands
under `~/.local/bin`; these use the custom theme when available and otherwise
fall back to the packaged Rofi behavior. Select the i3 session at the login
screen, then use `Mod4+Shift+c` to reload the configuration after changes.

## Configuration changes

The following changes are included in the current local configuration.

### i3

- Increased the default gaps to `inner 8`, `outer 8`, and `top 32`. The top
  gap leaves an 8px visual separation below the 32px Polybar.
- Set Alacritty as the `$terminal` command and added `--no-startup-id` to the
  terminal and application launcher commands.
- Replaced the old PulseAudio volume commands with PipeWire `wpctl` commands.
- Added the `kali-rofi-launcher` and `kali-rofi-powermenu` wrapper commands.
- Added Flameshot bindings for `Print` and `Mod4+Shift+s`.
- Added the Flameshot and Picom startup commands.
- Corrected the Nautilus workspace assignment spacing.
- Replaced broken color variable names and invalid inactive-window color
  references with a consistent slate, cyan, and pink palette.
- Changed normal and floating windows to one-pixel borders.
- Changed the lock screen binding to use the configured lock color.
- Changed Variety startup from repeated execution to one execution per
  session.
- Removed the old Compton startup and the unused xbacklight and touchpad
  placeholder bindings.

### Polybar

- Replaced the four separate bars with one `main` bar.
- Set the bar to 99 percent width, 30px height, a 0.5 percent horizontal
  offset, a 1px vertical offset, and a 10px radius.
- Applied a slate background with cyan accents and improved workspace label
  colors and padding.
- Kept i3 workspaces and date on the bar, with network, audio, memory, CPU,
  filesystem, and tray modules on the right.
- Added an internal system tray for Flameshot and other tray applications.
- Improved the filesystem, muted-audio, Ethernet, and date labels.
- Reworked `polybar/launch.sh` to use the installed config path, store logs in
  `${XDG_STATE_HOME:-$HOME/.local/state}/polybar`, stop existing bars through
  Polybar IPC when available, and launch only the `main` bar.

### Alacritty

- Added `alacritty/alacritty.toml` for the current Alacritty configuration.
- Disabled window decorations and set opacity to `0.98`.
- Set Iosevka Regular, Bold, and Italic at size 15.
- Set terminal padding to `x=18, y=4`; the low vertical value removes excess
  space inside the terminal while i3 provides the bar separation.
- Added the slate terminal palette, cyan beam cursor, 10,000 lines of scroll
  history, clipboard selection saving, and hide-cursor-on-typing behavior.

### Picom

- Added `picom/picom.conf` and switched i3 from Compton to Picom.
- Configured the XRender backend for the VMware X11 session.
- Added 14px rounded corners and rounded borders, excluding dock and desktop
  windows.
- Added soft shadows with a 16px radius and 0.24 opacity.
- Enabled VSync and rounded-corner detection, with fading disabled.

### Flameshot

- Added Flameshot to the installer package list.
- Added `scripts/flameshot-x11.sh`, which unsets `WAYLAND_DISPLAY` and forces
  the Qt XCB backend before starting Flameshot.
- Enabled `useX11LegacyScreenshot=true` because this is an i3/X11 session and
  the desktop screenshot portal was timing out.
- Kept the configured save directory at
  `/home/hashghost/Pentest/VOP/retest`.
- Flameshot full-screen capture was verified by saving a valid PNG locally.

### Rofi and installer

- Added `scripts/rofi-launcher.sh`, which uses the custom type-5 or type-3
  launcher when installed and otherwise falls back to `rofi -show drun`.
- Added `scripts/powermenu.sh`, which uses the custom power menu when
  installed and otherwise provides Lock, Suspend, Logout, Reboot, and
  Shutdown actions with confirmation prompts.
- Reworked `setup.sh` to resolve paths from its own location, use strict Bash
  error handling, install the required packages, create destination
  directories, and install each config with explicit permissions.
- Added optional Rofi setup handling without assuming that the Rofi theme
  directory is present.
- Added the IBus setting that hides its keyboard-layout indicator from the
  Polybar tray while keeping IBus available for input methods.
- Added Flameshot, Picom, Alacritty, PipeWire, and related desktop packages to
  the installer.

### Shell prompt

- Changed the repository `.zshrc` and live `~/.zshrc` setting
  `NEWLINE_BEFORE_PROMPT` from `yes` to `no` so each prompt does not add an
  unnecessary blank line below the bar.
- Preserved the live `.zshrc` additions for the local `PATH`, Oh My Posh, and
  OpenCode environment.

## Main keybindings

| Key | Action |
| --- | --- |
| `Mod4+Return` | Open Alacritty |
| `Mod4+d` | Open the Rofi application launcher |
| `Mod4+x` | Open the power menu |
| `Print` | Open Flameshot region capture |
| `Mod4+Shift+s` | Open Flameshot region capture |
| `Mod4+q` | Close the focused window |
| `Mod4+1` through `Mod4+0` | Switch workspaces |
| `Mod4+Shift+c` | Reload i3 |
| `Mod4+Shift+r` | Restart i3 |
| `Mod4+Shift+x` | Lock the screen |

## Wallpaper

Wallpaper management is handled by Variety. Replace the `variety --resume`
startup command in `i3/config` if another wallpaper tool is preferred.

## Notes

Polybar is the active status bar. `i3/i3blocks.conf` is retained as an
optional fallback configuration but is not started by the default i3 config.
Its network block no longer hard-codes `tun0` and now refreshes every five
seconds when used.

The related Hyprland VMware workaround files under `ricing/` are separate from
this i3 configuration and are not part of the changes documented above.
