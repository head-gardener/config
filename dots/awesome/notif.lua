local naughty = require("naughty")
local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local M = {}

M.notification_history = {}
M.max_history = 100

M.popups = {}
M.buttons = {}

function M.add_notification(args)
  table.insert(M.notification_history, 1, {
    title = args.title or "",
    text = args.text or "",
    app_name = args.app_name or "unknown",
    timestamp = os.time(),
  })

  if #M.notification_history > M.max_history then
    table.remove(M.notification_history)
  end

  for _, button in pairs(M.buttons) do
    button:set_text("  " .. #M.notification_history .. " ⚠  ")
  end
end

function M.clear_notifications()
  M.notification_history = {}
  for s, popup in pairs(M.popups) do
    if popup.visible then
      M.refresh_popup(s)
    end
  end
  for _, button in pairs(M.buttons) do
    button:set_text("  0 ⚠  ")
  end
end

function M.remove_notification(index)
  table.remove(M.notification_history, index)
  for s, popup in pairs(M.popups) do
    if popup.visible then
      M.refresh_popup(s)
    end
  end
  for _, button in pairs(M.buttons) do
    button:set_text("  " .. #M.notification_history .. " ⚠  ")
  end
end

function M.create_notification_widget(notif, index)
  local time_str = os.date("%H:%M", notif.timestamp)
  local title_text = notif.title ~= "" and notif.title or notif.app_name

  local title_box = wibox.widget.textbox()
  title_box:set_markup("<b>" .. title_text .. "</b>")

  local time_box = wibox.widget.textbox()
  time_box:set_text(time_str)

  local header = wibox.layout.align.horizontal()
  header:set_first(title_box)
  header:set_third(time_box)

  local text_box = wibox.widget.textbox()
  text_box:set_text(notif.text)

  local inner = wibox.layout.fixed.vertical()
  inner:add(header)
  inner:add(text_box)

  local margin = wibox.container.margin(inner, 12, 12, 8, 8)

  local bordered = wibox.widget {
    margin,
    shape = gears.shape.rounded_rect,
    border_width = 1,
    border_color = beautiful.border_normal or "#45475a",
    bg = beautiful.bg_normal or "#1e1e2e",
    widget = wibox.container.background,
  }

  bordered:buttons(gears.table.join(
    awful.button({}, 1, function()
      M.remove_notification(index)
    end)
  ))

  return wibox.container.margin(bordered, 0, 0, 4, 4)
end

function M.refresh_popup(s)
  local popup = M.popups[s]
  if not popup then return end

  local main_layout = wibox.layout.fixed.vertical()
  main_layout.spacing = 10

  -- Header with title and clear button
  local title_header = wibox.layout.align.horizontal()
  local title_box = wibox.widget.textbox()
  title_box:set_markup("<b>Notification Center</b>")
  title_header:set_first(title_box)

  local clear_box = wibox.widget.textbox()
  clear_box:set_markup("<u>Clear All</u>")
  clear_box:buttons(gears.table.join(
    awful.button({}, 1, function()
      M.clear_notifications()
    end)
  ))
  title_header:set_third(clear_box)

  main_layout:add(title_header)

  -- Notifications
  if #M.notification_history == 0 then
    local empty = wibox.widget.textbox()
    empty:set_text("No notifications")
    main_layout:add(empty)
  else
    for i, notif in ipairs(M.notification_history) do
      main_layout:add(M.create_notification_widget(notif, i))
    end
  end

  popup:set_widget(main_layout)
end

function M.toggle_popup(s)
  local popup = M.popups[s]
  if not popup then
    M.create_popup(s)
    popup = M.popups[s]
  end

  if popup.visible then
    popup.visible = false
  else
    M.refresh_popup(s)
    popup.visible = true
  end
end

function M.create_popup(s)
  local geo = s.geometry
  local popup_height = math.floor(geo.height * 0.8)

  local popup = awful.popup({
    screen = s,
    ontop = true,
    visible = false,
    bg = beautiful.bg_normal or "#1e1e2e",
    fg = beautiful.fg_normal or "#cdd6f4",
    border_width = beautiful.border_width or 1,
    border_color = beautiful.border_focus or "#89b4fa",
    minimum_width = 350,
    maximum_width = 350,
    minimum_height = popup_height,
    maximum_height = popup_height,
    placement = awful.placement.right,
    widget = wibox.layout.fixed.vertical(),
  })

  M.popups[s] = popup
end

function M.create_button(s)
  local button = wibox.widget.textbox()
  button:set_text("  0 ⚠  ")

  button:buttons(gears.table.join(
    awful.button({}, 1, function()
      M.toggle_popup(s)
    end)
  ))

  M.buttons[s] = button
  return button
end

function M.init()
  local original_callback = naughty.config.notify_callback
  naughty.config.notify_callback = function(args)
    if original_callback then
      args = original_callback(args)
      if not args then return nil end
    end

    M.add_notification(args)
    return args
  end
end

return M
