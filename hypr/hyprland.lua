-- @!os:linux
-- @!user:dracowizard
-- @!install:644:$HOME/.config/hypr/hyprland.lua

require("local")

hl.config({
    input = {
        kb_layout = "us",
        kb_options = "ctrl:nocaps compose:menu",
        follow_mouse = 1,
    },
    general = {
        gaps_in = 1,
        gaps_out = 2,
        border_size = 1,
        resize_on_border = true,
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        allow_tearing = true,
        layout = "dwindle",
    },
    render = {
        cm_auto_hdr = 1,
        cm_sdr_eotf = "srgb",
    },
    gestures = {
        workspace_swipe_use_r = true,
    },
    decoration = {
        rounding = 3,
        blur = {
            enabled = false,
            size = 6,
            passes = 1,
        },
        shadow = {
            enabled = false,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
    },
    misc = {
        force_default_wallpaper = 0,
        key_press_enables_dpms = true,
    },
    xwayland = {
        force_zero_scaling = true,
    },
    dwindle = {
        preserve_split = true,
        special_scale_factor = 1,
    },
})

hl.device({ name = "kmonad-razer-naga-trinity-1", sensitivity = -0.9 })
hl.device({ name = "razer-razer-naga-trinity-2",  sensitivity = -0.9 })
hl.device({ name = "razer-razer-naga-trinity-3",  sensitivity = -0.9 })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "up", action = "special", workspace_name = "term" })
hl.gesture({ fingers = 3, direction = "down", action = "special", workspace_name = "general" })

hl.curve("ease_in_sine",     { type = "bezier", points = { {0.47, 0},    {0.745, 0.715} } })
hl.curve("ease_out_sine",    { type = "bezier", points = { {0.39, 0.575}, {0.565, 1}     } })
hl.curve("ease_in_out_sine", { type = "bezier", points = { {0.445, 0.05}, {0.55, 0.95}   } })

hl.config({ animations = { enabled = true } })

hl.animation({ leaf = "layers",           enabled = true, speed = 2, bezier = "ease_out_sine",    style = "popin" })
hl.animation({ leaf = "windows",          enabled = true, speed = 2, bezier = "ease_out_sine",    style = "popin" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 2, bezier = "ease_in_out_sine", style = "slide" })
hl.animation({ leaf = "fade",             enabled = true, speed = 2, bezier = "ease_in_out_sine" })
hl.animation({ leaf = "fadeIn",           enabled = true, speed = 2, bezier = "ease_out_sine" })
hl.animation({ leaf = "fadeOut",          enabled = true, speed = 2, bezier = "ease_in_sine" })
hl.animation({ leaf = "fadeLayers",       enabled = true, speed = 2, bezier = "ease_in_out_sine" })
hl.animation({ leaf = "fadeLayersIn",     enabled = true, speed = 2, bezier = "ease_out_sine" })
hl.animation({ leaf = "fadeLayersOut",    enabled = true, speed = 2, bezier = "ease_in_sine" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 2, bezier = "ease_in_out_sine", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "ease_out_sine",    style = "slidefadevert 20%" })

hl.layer_rule({ match = { namespace = "quickshell" }, blur = true })
hl.layer_rule({ match = { namespace = "selection" }, animation = "fade" })

-- Float rules
hl.window_rule({ match = { title = "([Oo]pen|[Ss]elect) ([Ff]ile|[Ff]older|[Dd]ir(ectory)?)(.*)" }, float = true })
hl.window_rule({ match = { title = "([Ss]ave [Aa]s|[Ll]ibrary)(.*)" },                              float = true })
hl.window_rule({ match = { class = "org\\.kde\\.polkit-kde-authentication-agent-1" },                float = true })
hl.window_rule({ match = { class = "org\\.gnupg\\.pinentry-qt" },                                    float = true })
hl.window_rule({ match = { class = "puzzles-" },                                                     pseudo = true })

-- Stay-focused rules
hl.window_rule({ match = { class = "org\\.kde\\.polkit-kde-authentication-agent-1" }, stay_focused = true })
hl.window_rule({ match = { class = "org\\.gnupg\\.pinentry-qt" },                          stay_focused = true })

-- Special workspace rules
hl.window_rule({ match = { class = "thunderbird" },              workspace = "special:general" })
hl.window_rule({ match = { class = "discord" },                  workspace = "special:general" })
hl.window_rule({ match = { class = "org\\.telegram\\.desktop" }, workspace = "special:general" })
hl.window_rule({ match = { class = "vlc" },                      workspace = "special:general" })
hl.window_rule({ match = { class = "signal" },                   workspace = "special:general" })
hl.window_rule({ match = { title = "WhatsApp Web" },             workspace = "special:general" })
hl.window_rule({ match = { title = "WhatsApp Web" },             tile = true })

-- Fullscreen/immediate rules
hl.window_rule({ match = { title = "Space Engineers" }, fullscreen = true, immediate = true })
hl.window_rule({ match = { class = "gamescope" },        immediate = true })

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- wezterm start", { workspace = "special:term silent" })
    hl.exec_cmd("systemctl --user start wireplumber.service hypridle.service hyprpolkitagent.service mako.service")
    hl.exec_cmd("uwsm app -- playerctld daemon")
    hl.exec_cmd("uwsm app -- quickshell")
end)

-----------------------
----  KEYBINDINGS  ----
-----------------------

-- Media keys
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"),  { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("light -A 3"),                                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("light -U 3"),                                  { locked = true, repeating = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"),                       { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),                             { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),                         { locked = true })

-- Special workspaces
hl.bind("F12",                  hl.dsp.workspace.toggle_special("term"))
hl.bind("WIN + M",              hl.dsp.workspace.toggle_special("term"))
hl.bind("WIN + SHIFT + M",      hl.dsp.window.move({ workspace = "special:term" }))
hl.bind("Menu",                 hl.dsp.workspace.toggle_special("general"))
hl.bind("WIN + N",              hl.dsp.workspace.toggle_special("general"))
hl.bind("WIN + SHIFT + N",      hl.dsp.window.move({ workspace = "special:general" }))

-- Window management
hl.bind("WIN + C",              hl.dsp.window.close())
hl.bind("WIN + Q",              hl.dsp.exec_cmd("uwsm stop"))
hl.bind("WIN + SHIFT + Q",      hl.dsp.exit())
hl.bind("WIN + SHIFT + S",      hl.dsp.exec_cmd("wezterm start"))
hl.bind("WIN + F",              hl.dsp.exec_cmd("uwsm app -- neovide.desktop"))
hl.bind("WIN + D",              hl.dsp.exec_cmd("~/.config/hypr/launcher.sh"))
hl.bind("WIN + S",              hl.dsp.exec_cmd("uwsm app -- org.wezfurlong.wezterm.desktop"))
hl.bind("WIN + R",              hl.dsp.exec_cmd("uwsm app -- brave-browser.desktop:new-window"))

-- Workspace navigation
hl.bind("WIN + Y",              hl.dsp.window.fullscreen({ toggle = true }))
hl.bind("WIN + U",              hl.dsp.focus({ workspace = "r-1" }))
hl.bind("WIN + I",              hl.dsp.focus({ workspace = "r+1" }))
hl.bind("WIN + Semicolon",      hl.dsp.exec_cmd("take-screenshot.zsh"))
hl.bind("WIN + SHIFT + U",      hl.dsp.window.move({ workspace = "r-1" }))
hl.bind("WIN + SHIFT + I",      hl.dsp.window.move({ workspace = "r+1" }))
hl.bind("WIN + SHIFT + O",      hl.dsp.window.move({ monitor = -1 }))
hl.bind("WIN + SHIFT + P",      hl.dsp.window.move({ monitor = 1 }))

-- Mouse wheel workspace switching
hl.bind("WIN + mouse_down",     hl.dsp.focus({ workspace = "r+1" }))
hl.bind("WIN + mouse_up",       hl.dsp.focus({ workspace = "r-1" }))

-- Focus movement
hl.bind("WIN + H",              hl.dsp.focus({ direction = "left" }))
hl.bind("WIN + J",              hl.dsp.focus({ direction = "down" }))
hl.bind("WIN + K",              hl.dsp.focus({ direction = "up" }))
hl.bind("WIN + L",              hl.dsp.focus({ direction = "right" }))

-- Window movement
hl.bind("WIN + SHIFT + H",      hl.dsp.window.move({ direction = "left" }))
hl.bind("WIN + SHIFT + J",      hl.dsp.window.move({ direction = "down" }))
hl.bind("WIN + SHIFT + K",      hl.dsp.window.move({ direction = "up" }))
hl.bind("WIN + SHIFT + L",      hl.dsp.window.move({ direction = "right" }))

-- Toggle floating
hl.bind("WIN + Space",          hl.dsp.window.float({ action = "toggle" }))

-- Mouse binds
hl.bind("WIN + mouse:272",      hl.dsp.window.drag(),   { mouse = true })
hl.bind("WIN + mouse:273",      hl.dsp.window.resize(), { mouse = true })

-- Commented-out binds from old config:
-- hl.bind("WIN + Q", hl.dsp.exec_cmd("pkill wlogout || wlogout -p layer-shell"))
-- hl.bind("WIN + E", hl.dsp.exec_cmd("~/.config/hypr/wezterm-remotes.sh"))
-- hl.bind("WIN + R", hl.dsp.exec_cmd("uwsm app -- brave-browser.desktop:new-window --profile-directory=Default --enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4"))
-- hl.bind("WIN + V", hl.dsp.exec_cmd("wofi --show run"))
-- hl.bind("WIN + O", hl.dsp.layout("togglesplit"))  -- togglesplit doesn't exist in 0.55
-- hl.bind("WIN + Semicolon", hl.dsp.exec_cmd("hyprshot -m region -s -o ~/Pictures -z"))
