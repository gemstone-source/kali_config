#!/bin/bash 

#install i3 
sudo apt update 
sudo apt install i3 -y&& sudo apt install feh  -y && sudo apt install arandr -y && sudo apt install lxappearance -y
sudo apt install nitrogen -y && sudo apt install thunar -y && sudo apt install rofi -y  && sudo apt install i3blocks -y
sudo apt install gnome-terminal -y

# Setting i3 config files
mkdir ~/.config/i3
cp i3/* ~/.config/i3/

# Setting gtk themes
touch ~/.gtkrc-2.0
cp .gtkrc-2.0 ~/.gtkrc-2.0 
cp  gtk-3.0/* ~/.config/

# Configurations for vim editor
touch ~/.vimrc
cp .vimrc ~/.vimrc 

# Setting zsh environment
# cp .zshrc ~/.zshrc 

# Rofi setup
git clone --depth=1 https://github.com/adi1090x/rofi.git
cd rofi
chmod +x setup.sh
./setup.sh
mv ~/.config/rofi/config.rasi  ~/.config/rofi/config

# Download arc-themes
echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/Debian_8.0/ /' | sudo tee /etc/apt/sources.list.d/home:Horst3180.list
curl -fsSL https://download.opensuse.org/repositories/home:Horst3180/Debian_8.0/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_Horst3180.gpg > /dev/null
sudo apt update -y
sudo apt install arc-theme

# Download fonts
wget https://github.com/supermarin/YosemiteSanFranciscoFont/archive/master.zip 
unzip master.zip 
cd YosemiteSanFranciscoFont-master 
mkdir ~/.fonts
mv *.ttf ~/.fonts
