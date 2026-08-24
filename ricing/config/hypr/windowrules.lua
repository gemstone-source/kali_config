-- App -> workspace pinning (Omarchy-style workflow)
--
-- Hyprland 0.56 Lua rule syntax:
--   hl.window_rule({ match = { class = "regex" }, workspace = "N" })
--
-- Find a window's exact class by running:  hyprctl clients
--
--   workspace 1: terminals
--   workspace 2: browsers
--   workspace 3: file managers
--   workspace 4: notes, code editors, obsidian
--   workspace 5: Spotify

-- --- Workspace 1: terminals ---
hl.window_rule({ match = { class = "^(foot|alacritty|kitty|wezterm|gnome-terminal-server)$" }, workspace = "1" })

-- --- Workspace 2: browsers ---
-- Firefox on Kali is usually installed as Firefox ESR, whose class is
-- `firefox-esr` rather than `firefox`.
hl.window_rule({ match = { class = "^(firefox|firefox-esr|firefox-developer-edition|firefox-nightly|chromium|chromium-browser|google-chrome|google-chrome-beta|google-chrome-unstable|brave-browser|brave-browser-nightly|librewolf|microsoft-edge|microsoft-edge-dev|vivaldi|vivaldi-stable|opera|opera-developer|waterfox|floorp|zen|qutebrowser|thorium-browser)$" }, workspace = "2" })

-- --- Workspace 3: file managers ---
hl.window_rule({ match = { class = "^(org.gnome.Nautilus|dolphin|org.kde.dolphin|thunar|pcmanfm|nemo)$" }, workspace = "3" })

-- --- Workspace 4: notes, editors, obsidian ---
hl.window_rule({ match = { class = "^(obsidian|code|code-oss|code-url-handler|codium|sublime_text|gedit)$" }, workspace = "4" })

-- --- Workspace 5: Spotify ---
hl.window_rule({ match = { class = "^(spotify|Spotify|com.spotify.Client)$" }, workspace = "5" })
