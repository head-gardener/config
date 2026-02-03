local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local data = {
  {
    done = false,
    msg = 'do me!',
  },
  {
    done = true,
    msg = 'i\'m done',
  },
}

local M = {}

M.widget = wibox.widget {
  {
    id = "txt",
    widget = wibox.widget.textbox,
  },
  set_text = function(self, new_value)
    self:get_children_by_id("txt")[1].text = new_value
  end,
  ontop = true,
}

local function worker(_)
  -- local args = args or {}
  -- function update_widget(stdout)
  -- end
  return M.widget
end

return setmetatable(M, { __call = worker })
