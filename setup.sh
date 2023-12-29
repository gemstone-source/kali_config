#!/bin/bash 

#install i3 
sudo apt update -y
sudo apt install i3 -y && sudo apt install variety  -y && sudo apt install arandr -y && sudo apt install lxappearance -y
sudo apt install nitrogen -y && sudo apt install thunar -y && sudo apt install rofi -y  && sudo apt install i3blocks -y
sudo apt install gnome-terminal -y && sudo apt install compton -y && sudo apt install polybar -y && sudo apt install i3-gaps -y

# Setting i3 config files
mkdir ~/.config/i3
cp i3/* ~/.config/i3/
cp pictures -r ~/.config/i3 

# Setting polybar
mkdir ~/.config/polybar
cp -r polybar ~/.config/

# Setting gtk themes
# touch ~/.gtkrc-2.0
# cp .gtkrc-2.0 ~/.gtkrc-2.0 
# cp  gtk-3.0/* ~/.config/

# Configurations for vim editor
touch ~/.vimrc
cp .vimrc ~/.vimrc 

# Setting zsh environment
cp .zshrc ~/.zshrc 

# Install Alacritty Terminal
wget https://github.com/barnumbirr/alacritty-debian/releases/download/v0.10.0-rc4-1/alacritty_0.10.0-rc4-1_amd64_bullseye.deb
sudo dpkg -i alacritty_0.10.0-rc4-1_amd64_bullseye.deb
sudo apt install -f

mkdir -p ~/.config/alacritty
cp alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

# Rofi setup
git clone --depth=1 https://github.com/adi1090x/rofi.git
cd rofi
chmod +x setup.sh
./setup.sh
mv ~/.config/rofi/config.rasi  ~/.config/rofi/config

# Download fonts
cd ..
# mkdir ~/.fonts
# wget https://github.com/supermarin/YosemiteSanFranciscoFont/archive/master.zip 
# unzip master.zip 
# mv YosemiteSanFranciscoFont-master/*.ttf ~/.fonts

# Touchpad settings
sudo mkdir -p /etc/X11/xorg.conf.d && sudo tee <<'EOF' /etc/X11/xorg.conf.d/90-touchpad.conf 1> /dev/null
Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
EndSection

EOF

printf "\nReboot your machine now and select i3 environment before you log in"
