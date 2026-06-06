local naughty = require("naughty")
local awful = require("awful")
local gears = require("gears")
local string = require("string")
local wibox = require("wibox")

-- x11 selection
local selection = selection

local function fuzzy_tool_select(title, items, on_select)
  local beautiful = require("beautiful")
  local awesomex = require("awesomex")

  local runner = awesomex.widget.fuzzy_select {
    title = title,
    source = function() return items end,
    filter = function(q, name) return awesomex.fzy.has_match(q, name) end,
    sort = function(q, a, b) return awesomex.fzy.score(q, a) > awesomex.fzy.score(q, b) end,
    item = function(name)
      return wibox.widget {
        {
          text = "  " .. name,
          font = beautiful.font,
          widget = wibox.widget.textbox,
        },
        margins = 6,
        widget = wibox.container.margin,
      }
    end,
    keybindings = {
      {{'Control'}, 'j', function(self)
        local name = self.fuzzy.selected_item.value
        self:stop()
        if name then on_select(name) end
      end},
      {{}, 'Return', function(self)
        local name = self.fuzzy.selected_item.value
        self:stop()
        if name then on_select(name) end
      end},
      {{'Control'}, 'n', function(self) self.fuzzy:select_next() end},
      {{'Control'}, 'p', function(self) self.fuzzy:select_previous() end},
      {{}, 'Down', function(self) self.fuzzy:select_next() end},
      {{}, 'Up', function(self) self.fuzzy:select_previous() end},
    },
  }
  runner.bg = beautiful.bg_normal
  runner.minimum_width = 320
  runner.maximum_height = 480
  runner.screen = awful.screen.focused()
  runner:run()
end

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
  local handle = io.popen("cat $HOME/.ssh/known_hosts 2>/dev/null | cut -d ' ' -f 1 | sort -u")
  if not handle then return end
  local hosts = {}
  for host in handle:lines() do
    table.insert(hosts, host)
  end
  handle:close()
  table.sort(hosts)

  fuzzy_tool_select('SSH', hosts, function(host)
    local _, _, h, p = string.find(host, "%[(.+)%]:(%d+)")
    if h and p then
      awful.spawn("kitty ssh " .. sh(h) .. " -p " .. sh(p))
    else
      awful.spawn("kitty ssh " .. sh(host))
    end
  end)
end

function M.pass()
    awful.spawn("passmenu")
end

function M.note()
  awful.spawn([[kitty fish -c "note --select"]])
end

function M.note_search()
  local cmd = "kitty notesearch search"
  awful.spawn(cmd)
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
    { name = "tailscaled.service", system = true },
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
  local tool_map = {}
  local tool_names = {}
  for n, f in pairs(M) do
    if n ~= "cmds" and n ~= "config" then
      table.insert(tool_names, n)
      tool_map[n] = f
    end
  end
  table.sort(tool_names)

  fuzzy_tool_select('Tools', tool_names, function(name)
    if tool_map[name] then tool_map[name]() end
  end)
end

return setmetatable(M, { __call =  init })
