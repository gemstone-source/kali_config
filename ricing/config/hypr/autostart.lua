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
end)
