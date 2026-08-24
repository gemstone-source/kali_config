# Installation

## 1. Clone

```bash
git clone <your-repo-url> ricing
cd ricing
```

## 2. Run the installer

```bash
./setup.sh
```

What it does:

1. `apt update`
2. Installs every package in `packages.list`
3. Downloads and installs the **JetBrainsMono Nerd Font**
4. Installs the `rice` and `rice-stats` CLIs into `~/.local/bin`
5. Symlinks configs from the repo into `~/.config` (backing up any conflicts)
6. Copies the five anime wallpapers into `~/.local/share/riceshell/wallpapers/anime`
7. Sets your default shell to `zsh` if it isn't already
8. Applies the default `gemstone` theme

The installer is idempotent — run it as many times as you like. Existing configs
are backed up as `<name>.bak.<timestamp>` instead of being overwritten.

## 3. Log in to Hyprland

Log out and select **Hyprland** from the session menu at the login screen.

## Manual per-step install

If you prefer to do it by hand:

```bash
sudo apt update
sudo apt install -y $(grep -v '^#' packages.list | tr '\n' ' ')
mkdir -p ~/.local/bin && ln -sf "$PWD/bin/rice" ~/.local/bin/rice
# then run rice theme set gemstone, and symlink the configs you want
```

## Uninstall

```bash
rm -rf ~/.config/hypr ~/.config/quickshell ~/.config/nvim \
       ~/.config/foot ~/.config/wofi ~/.config/dunst ~/.config/waybar \
       ~/.config/starship.toml ~/.config/fastfetch ~/.config/riceshell \
       ~/.local/bin/rice
```

Then `sudo apt autoremove --purge hyprland quickshell` if you want the packages
gone too.
