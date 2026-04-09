local io = io

local gears = require("gears")
local wibox = require("wibox")

local batt = { mt = {} }

local function read(filename)
  local handle = io.open(filename, "r")
  if handle == nil then
    return nil
  end

  local result = handle:read("*a")
  handle:close()

  return result
end

local function new()
  -- battery detection
  -- error handling
  local w = wibox.widget.textbox()
  gears.table.crush(w, batt, true)

  do
    local e = tonumber(read("/sys/class/power_supply/BAT0/energy_full"))
    local p = tonumber(read("/sys/class/power_supply/BAT0/power_now"))
    w._private.energy_full = e
    w._private.power_avg = p
  end

  function w.update()
    local energy_now = tonumber(read("/sys/class/power_supply/BAT0/energy_now"))
    local power_now = tonumber(read("/sys/class/power_supply/BAT0/power_now"))

    -- better running avg
    w._private.power_avg = (w._private.power_avg + 2 * power_now) / 3
    local left_hours, left_minutes = math.modf(energy_now / w._private.power_avg)

    -- leftpad
    local txt = string.format(
      "%i%% (%i:%i)",
      100 * energy_now / w._private.energy_full,
      left_hours,
      left_minutes * 60
    )
    w:set_text(txt)
  end

  -- replace with fsnotify
  gears.timer {
    timeout   = 5,
    call_now  = true,
    autostart = true,
    callback  = w.update
  }

  return w
end

function batt.mt:__call()
  return new()
end

return setmetatable(batt, batt.mt)
