-- Work laptop monitor layout and dock/lid-switch handling.

hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })

-- Catch-all for the dock's monitor(s) until they get a proper desc:-pinned
-- rule (needs physical dock access to read the EDID description).
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- Deliberately no static workspace->monitor pinning here: Hyprland's default
-- (lowest free workspace goes to whichever monitor appears first) is what
-- makes an undocked boot land on workspace 1 on eDP-1, instead of every
-- workspace being locked to the dock's monitor and Hyprland auto-creating
-- workspace 11/12 when only eDP-1 exists.

-- Lid switch + monitor recovery. Routed through the native hl.monitor()
-- call (confirmed working re-enable path) rather than "hyprctl keyword
-- monitor" (broken re-enable path for the last active output on Hyprland
-- 0.56.x). Excludes the synthetic "FALLBACK" monitor Hyprland creates when
-- zero real outputs remain, which otherwise fools this exact check.
local function other_real_monitor_active()
  local f = io.popen("hyprctl monitors -j | jq '[.[] | select(.name != \"eDP-1\" and .name != \"FALLBACK\" and .disabled == false)] | length'")
  local n = tonumber(f:read("*a"))
  f:close()
  return (n or 0) > 0
end

local function ensure_internal_display()
  if not other_real_monitor_active() then
    hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1, disabled = false })
  end
end

-- Dock unplugged while the lid was already closed: nothing else reacts to
-- a monitor disappearing, so this is what brings the internal panel back
-- instead of leaving zero active outputs.
hl.on("monitor.removed", ensure_internal_display)

hl.bind("switch:off:Lid Switch", ensure_internal_display, { locked = true })

hl.bind("switch:on:Lid Switch", function()
  if other_real_monitor_active() then
    hl.monitor({ output = "eDP-1", disabled = true })
  else
    hl.dsp.exec_cmd("systemctl suspend")
  end
end, { locked = true })
