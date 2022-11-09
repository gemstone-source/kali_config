# i3 window manager
This is dotfile configuration for clean linux installed it has basically aimed to install and configure i3 window manager environment and the srcipt has beeen tested on kali linux feel free to customize it the way you like.
## Usage 
Clone this repository and then run the setup.sh script

```
git clone https://github.com/gemstone-source/kali_config.git
cd kali_config
chmod +x setup.sh 
./setup.sh
```
## Images after configuration
![image](pictures/i3.png)

![image](pictures/i3wm.png)

## Note 
You can change wallpaper the way you want to and to do so just change this line from `i3/config` to the location where your wallpapers are
```
exec --no-startup-id nitrogen  --set-auto  ./pictures/05.jpg --head=0 && nitrogen --set-auto ./pictures/05.jpg --head=1
```
Replace `./pictures/05.jpg` with your wallpaper path.

Also visit [rofi_advanced](https://github.com/adi1090x/rofi) for more customization of `rofi`

## References.
[rofi_advanced](https://github.com/adi1090x/rofi)

[theme](https://software.opensuse.org/download.html?project=home%3AHorst3180&package=arc-theme)

[fonts](https://github.com/supermarin/YosemiteSanFranciscoFont)

[i3wm_official_site](https://i3wm.org/)