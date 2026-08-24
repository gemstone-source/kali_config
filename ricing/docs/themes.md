# Themes

Themes are a single palette file: `themes/<name>/colors.toml`.

```bash
rice theme list            # list themes
rice theme current         # show active theme
rice theme set tokyo-night # apply a theme
```

`rice theme set` renders the palette into **every** application at once:

- foot (`~/.config/foot/foot.ini`)
- Neovim (`~/.config/nvim/lua/theme.lua`)
- dunst (`~/.config/dunst/dunstrc`)
- wofi (`~/.config/wofi/style.css`)
- Quickshell (`~/.config/quickshell/Colors.qml`)
- starship (`~/.config/starship.toml`)
- fastfetch (`~/.config/fastfetch/config.jsonc`)
- Hyprland (`~/.config/hypr/theme.lua`)
- hyprlock (`~/.config/hypr/hyprlock.conf`)
- Waybar (`~/.config/waybar/style.css`)

## Included themes

| Name | Description |
|---|---|
| `gemstone` | Midnight-violet default theme (default) |
| `tokyo-night` | Tokyo Night |
| `catppuccin-mocha` | Catppuccin Mocha |
| `everforest` | Everforest Dark |

## Palette keys

```toml
[colors]
bg = "0e0e16"        # background
bg_alt = "15151f"    # bar / popup background
fg = "e2e2ea"        # foreground
fg_dim = "6c6c85"    # secondary text
border = "2a2a3d"    # borders
accent = "a78bfa"    # primary accent
accent_fg = "0e0e16" # text on accent

black  = "..."       # ANSI 0..7
red    = "..."
green  = "..."
yellow = "..."
blue   = "..."
magenta= "..."
cyan   = "..."
white  = "..."

brblack  = "..."     # ANSI bright 0..7
brred    = "..."
brgreen  = "..."
bryellow = "..."
brblue   = "..."
brmagenta= "..."
brcyan   = "..."
brwhite  = "..."
```

Values are 6-digit hex **without** the leading `#`.

## Making your own theme

```bash
cp -r themes/gemstone themes/my-theme
$EDITOR themes/my-theme/colors.toml
rice theme set my-theme
```

Anime wallpapers live in `wallpapers/anime/` and are copied to
`~/.local/share/riceshell/wallpapers/anime/` by `setup.sh`. Quickshell displays
one static image and rotates to the next image every five minutes. Replace the
files in that directory if you want a different wallpaper set.
