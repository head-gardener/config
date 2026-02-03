local naughty = require("naughty")
local awful = require("awful")
local gears = require("gears")
local string = require("string")

local function sh(s)
  return("'" .. s .. "'")
end

local M = {}

local function init(config)
  local default = {}
  M.config = gears.table.crush(default, config, true)
  return M
end

function M.ssh()
  awful.spawn.easy_async_with_shell(
    "cat $HOME/.ssh/known_hosts | cut -d ' ' -f 1 | sort -u | dmenu",
    function (host, _, _, code)
      host = string.gsub(host, "%s+$", "")

      if code ~= 0 or host == "" then
        return
      end

      local _, _, h, p = string.find(host, "%[(.+)%]:(%d+)")

      if h ~= nil and p ~= nil then
        awful.spawn("kitty ssh " .. sh(h) .. " -p " .. sh(p))
        return
      end

      awful.spawn("kitty ssh " .. sh(host))
  end)
end

function M.pass()
    awful.spawn("passmenu")
end

function M.note()
  awful.spawn([[kitty fish -c "note --select"]])
end

function M.toggle()
  local units = {
    "keyd.service",
    "sing-box.service",
    "wg-quick-wg0.service",
  }

  local function is_active(unit, callback)
    awful.spawn.easy_async(
      'systemctl is-active ' .. unit,
      function (_, _, _, code)
        local active = code ~= 3
        callback(active)
    end)
  end

  local function toggle(unit)
    is_active(unit, function (active)
      local op = 'start'
      local verb = 'started'
      if active then
        op = 'stop'
        verb = 'stoped'
      end

      awful.spawn.easy_async('systemctl ' .. op .. ' ' .. unit, function (stdout, stderr, _, code)
        if code ~= 0 then
          naughty.notify({
            title = 'Unit ' .. unit .. ' failed ' .. op .. '!',
            text = 'Stdout:\n' .. stdout .. '\nStderr:\n' .. stderr,
            preset = naughty.config.presets.warn
          })
          return
        end

        naughty.notify({
          title = 'Unit ' .. unit .. ' ' .. verb .. '!',
          preset = naughty.config.presets.info
        })
      end)
    end)
  end

  local function mk_toggle(unit)
    return function ()
      toggle(unit)
    end
  end

  local menu = awful.menu({ })
  for _, v in pairs(units) do
    is_active(v, function (active)
      menu:add({
        (active and '●' or '○') .. ' ' .. v,
        mk_toggle(v),
      })
      menu:show()
    end)
  end
end

function M.cmds()
  local terms = {}
  for n, f in pairs(M) do
    if n == "cmds" or n == "config" then
      goto continue
    end
    table.insert(terms, { n, f, })
    ::continue::
  end
  awful.menu.new(terms):show()
end

return setmetatable(M, { __call =  init })
