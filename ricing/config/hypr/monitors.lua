-- Monitor setup — edit to match your displays.
-- The first rule is a sensible auto-detection default.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Examples (uncomment and edit):
-- hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1 })
-- hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@144", position = "1920x0", scale = 1 })

-- Persistent workspaces 1-10 (created at startup)
hl.workspace_rule({ workspace = "1", default = true })
for i = 2, 10 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end
