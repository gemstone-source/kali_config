#!/bin/bash 

#install i3 
sudo apt update 
sudo apt install i3 && sudo apt install feh && sudo apt install arandr && sudo apt install lxappearance
sudo apt install nitrogen && sudo apt install thunar && sudo apt install rofi

# Rofi setup
git clone --depth=1 https://github.com/adi1090x/rofi.git
cd rofi
chmod +x setup.sh
./setup.sh
mv ~/.config/rofi/config.rasi  ~/.config/rofi/config

# Download arc-themes
echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/Debian_8.0/ /' | sudo tee /etc/apt/sources.list.d/home:Horst3180.list
curl -fsSL https://download.opensuse.org/repositories/home:Horst3180/Debian_8.0/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_Horst3180.gpg > /dev/null
sudo apt update
sudo apt install arc-theme

# Download fonts
wget https://github.com/supermarin/YosemiteSanFranciscoFont/archive/master.zip 
unzip master.zip 
cd YosemiteSanFranciscoFont-master 
mkdir ~/.fonts
mv *.ttf ~/.fonts

# Setting i3 config files
cp i3/config i3/i3blocks.conf ~/.config/i3/

# Setting gtk themes
cp .gtkrc-2.0 ~/.gtkrc-2.0 
cp -r gtk-3.0 ~/.config/

# Setting zsh environment
# cp .zshrc ~/.zshrc