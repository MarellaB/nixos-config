-- Shared Hyprland config: look & feel, input, keybinds, lock screen.
-- Per-host monitor/workspace/lid-switch config lives in its own file
-- (desktop.lua / work-laptop.lua), required alongside this one.

local mod = "SUPER"

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    col = {
      active_border = "rgba(DDDDDDAA)",
      inactive_border = "rgba(DDDDDD33)",
    },
  },
  -- Forces new windows to always take the right/bottom half
  dwindle = {
    force_split = 2,
  },
  decoration = {
    rounding = 6,
    active_opacity = 1.0,
    inactive_opacity = 0.9,
  },
  cursor = {
    inactive_timeout = 2,
  },
  input = {
    kb_layout = "us,ua",
    follow_mouse = 1,
    repeat_rate = 70,
    repeat_delay = 250,
  }
})

hl.curve("easy", { type = "spring", mass = 1, stiffness = 714.36, dampening = 41.93 })

hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 1,
    spring = "easy",
})

hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 1,
    spring = "easy",
})

hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 1,
    bezier = "default",
})

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 2,
    bezier = "default",
    style = "slide",
})

-- Invert horizontal scrolling
hl.device({ name = "logitech-mx-master-4", scroll_points = "1 0 0 -1" })

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")

-- Keybindings
hl.bind(mod .. " + C", hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd("emacsclient -c -a ''"))
hl.bind(mod .. " + D", hl.dsp.exec_cmd("kitty yazi"))

hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.kill())
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + CTRL + SHIFT + 4", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind(mod .. " + CTRL + SHIFT + L", hl.dsp.exec_cmd("noctalia-lock"))
hl.bind(mod .. " + Space", hl.dsp.exec_cmd("noctalia-shell ipc call launcher toggle"))

-- Auto-center a window. Two dispatches chained in one bind, hence a
-- callback rather than a single hl.dsp.* expression like the other binds.
hl.bind(mod .. " + SHIFT + P", function()
  hl.dispatch(hl.dsp.window.resize({ x = 2560, y = 1440, relative = false }))
  hl.dispatch(hl.dsp.window.center())
end)
hl.bind(mod .. " + SHIFT + O", function()
  hl.dispatch(hl.dsp.window.resize({ x = 1920, y = 1080, relative = false }))
  hl.dispatch(hl.dsp.window.center())
end)

hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))

for i = 1, 10 do
  local key = i % 10
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia / brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("noctalia shell ipc call brightness increase"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("noctalia shell ipc call brightness decrease"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
