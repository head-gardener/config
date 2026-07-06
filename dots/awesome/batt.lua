local gears = require("gears")
local wibox = require("wibox")

local batt = { mt = {} }

local function find_battery()
  for i = 0, 2 do
    local path = "/sys/class/power_supply/BAT" .. i
    if gears.filesystem.is_dir(path) then return path end
  end
  return nil
end

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
  local bat_path = find_battery()
  if not bat_path then
    return wibox.widget.textbox("No battery")
  end

  local w = wibox.widget.textbox()
  gears.table.crush(w, batt, true)

  do
    local e = tonumber(read(bat_path .. "/energy_full"))
    local p = tonumber(read(bat_path .. "/power_now"))
    if not e or not p then
      return wibox.widget.textbox("Battery error")
    end
    w._private.energy_full = e
    w._private.power_avg = p
  end

  function w.update()
    local energy_now = tonumber(read(bat_path .. "/energy_now"))
    local power_now = tonumber(read(bat_path .. "/power_now"))
    local status = read(bat_path .. "/status")

    if not energy_now or not power_now then
      w:set_text("Batery error")
      return
    end

    local power = math.abs(power_now)
    local left_hours, left_minutes
    if power == 0 then
      w._private.power_avg = 0
    else
      w._private.power_avg = (w._private.power_avg + 2 * power) / 3
      left_hours, left_minutes = math.modf(energy_now / w._private.power_avg)
    end

    local txt = string.format(
      "%i%%",
      100 * energy_now / w._private.energy_full
    ) .. (w._private.power_avg > 0 and string.format(
      " (%i:%02i)",
      left_hours,
      left_minutes * 60
    ) or "")

    if status and status:match("Charging") then
      txt = "⚡ " .. txt
    end

    w:set_text(txt)
  end

  w._private.timer = gears.timer {
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
