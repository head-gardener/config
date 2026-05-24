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

function M.note_push()
  local sel = selection()
  local tmpfile = os.tmpname()
  local f = io.open(tmpfile, "w")
  if f then
    f:write(sel or "")
    f:close()
  end
  awful.spawn.easy_async(
    string.format(
      [[kitty fish -c ". /home/hunter/config/dots/fish/functions/note.fish; cat %s | note-push-interactive"]],
      tmpfile,
      tmpfile
    ),
    function (_, _, _, _)
      os.remove(tmpfile)
    end
  )
end

function M.toggle()
  local units = {
    { name = "keyd.service", system = true },
    { name = "sing-box.service", system = true },
    { name = "wg-quick-wg0.service", system = true },
    { name = "kdeconnectd.service", system = false },
  }

  local function systemctl(unit, op)
    local cmd = 'systemctl'
    if not unit.system then
      cmd = cmd .. ' --user'
    end
    return cmd .. ' ' .. op .. ' ' .. unit.name
  end

  local function is_active(unit, callback)
    awful.spawn.easy_async(systemctl(unit, 'is-active'), function (_, _, _, code)
      callback(code ~= 3)
    end)
  end

  local function toggle(unit)
    is_active(unit, function (active)
      local op = active and 'stop' or 'start'
      local verb = active and 'stoped' or 'started'

      awful.spawn.easy_async(systemctl(unit, op), function (stdout, stderr, _, code)
        if code ~= 0 then
          naughty.notify({
            title = 'Unit ' .. unit.name .. ' failed ' .. op .. '!',
            text = 'Stdout:\n' .. stdout .. '\nStderr:\n' .. stderr,
            preset = naughty.config.presets.warn
          })
          return
        end

        naughty.notify({
          title = 'Unit ' .. unit.name .. ' ' .. verb .. '!',
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
        (active and '●' or '○') .. ' ' .. v.name,
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
