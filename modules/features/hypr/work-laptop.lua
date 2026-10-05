-- Work laptop monitor layout and dock/lid-switch handling.

-- Reads the kernel's actual lid state rather than assuming open, every
-- config reload (e.g. every nixos-rebuild switch) re-runs this file, and
-- without this it would unconditionally re-enable eDP-1 even if the lid
-- is genuinely closed at the time.
local function lid_is_closed()
  local f = io.open("/proc/acpi/button/lid/LID0/state")
  local state = f:read("*a")
  f:close()
  return state:find("closed") ~= nil
end

hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1, disabled = lid_is_closed() })

-- Office dock's two Dell E2420Hs, pinned by EDID description
local dockLeft = "desc:Dell Inc. DELL E2420H 4R8WL83"
local dockRight = "desc:Dell Inc. DELL E2420H 4QVXL83"

hl.monitor({ output = dockLeft, mode = "preferred", position = "0x0", scale = 1 })
hl.monitor({ output = dockRight, mode = "preferred", position = "1920x0", scale = 1 })

for i = 1, 9 do
  hl.workspace_rule({ workspace = tostring(i), monitor = dockLeft })
end
hl.workspace_rule({ workspace = "10", monitor = dockRight })
-- These rules simply don't match when undocked, so eDP-1 keeps getting
-- whichever workspace is lowest and free, same as before.

-- Lid switch + monitor recovery. Excludes the synthetic "FALLBACK" monitor
-- Hyprland creates when zero real outputs remain.
local function other_real_monitor_active()
  for _, m in ipairs(hl.get_monitors()) do
    if m.name ~= "eDP-1" and m.name ~= "FALLBACK" then
      return true
    end
  end
  return false
end

-- Noctalia doesn't recompute its per-screen bar/wallpaper geometry when the
-- monitor set changes, leaving them rendered at a stale offset. Its own
-- "monitors off/on" IPC toggle forces that recompute.
local function refresh_noctalia_monitors()
  hl.dispatch(hl.dsp.exec_cmd("noctalia-refresh-monitors"))
end

local function enable_internal_display()
  hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1, disabled = false })
  refresh_noctalia_monitors()
end

-- Dock unplugged: suspend if the lid is actually closed right now, rather
-- than silently re-enabling eDP-1
hl.on("monitor.removed", function()
  if other_real_monitor_active() then return end
  if lid_is_closed() then
    hl.dispatch(hl.dsp.exec_cmd("systemctl suspend"))
  else
    enable_internal_display()
  end
end)

hl.bind("switch:off:Lid Switch", enable_internal_display, { locked = true })

hl.bind("switch:on:Lid Switch", function()
  if other_real_monitor_active() then
    hl.monitor({ output = "eDP-1", disabled = true })
    refresh_noctalia_monitors()
  else
    hl.dispatch(hl.dsp.exec_cmd("systemctl suspend"))
  end
end, { locked = true })
