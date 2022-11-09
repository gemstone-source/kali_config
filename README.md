# i3 window manager
This is dotfile configuration for clean linux installed it has basically aimed to install and configure i3 window manager environment and the srcipt has beeen tested on kali linux feel free to customize it the way you like.
## Usage 
Clone this repository and then run the setup.sh script

```
git clone https://github.com/gemstone-source/kali_config.git
cd kali_config
chmod +x setup.sh 
./setup,sh
```
## Images after configuration
![image](pictures/i3.png)

![image](pictures/i3wm.png)

## Note 
You can change wallpaper the way you want to and to do so just change this line from `i3/config` to the location where your wallpapers are
```
exec --no-startup-id nitrogen  --set-auto  ~/Pictures/Wallpapers/wallpaperflare.com_wallpaper.jpg --head=0 && nitrogen --set-auto ~/Pictures/Wallpapers/wallpaperflare.com_wallpaper.jpg --head=1
```
Replace `~/Pictures/Wallpapers/wallpaperflare.com_wallpaper.jpg` with your wallpaper path.