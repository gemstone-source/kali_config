-- Autostart (runs once when Hyprland starts).

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dunst")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("udiskie -t")
    hl.exec_cmd("hyprpolkitagent")
    hl.exec_cmd("/home/hashghost/.local/bin/wayland-to-x11-clipboard-watch")
    hl.exec_cmd("/home/hashghost/.local/bin/x11-to-wayland-clipboard-watch")
    hl.exec_cmd("env QT_QUICK_BACKEND=software QT_QPA_PLATFORMTHEME=gtk3 quickshell")
    -- VMware's user agent handles display resize events after host fullscreen changes.
    hl.exec_cmd("if command -v vmware-user-suid-wrapper >/dev/null 2>&1; then vmware-user-suid-wrapper; fi")
end)
