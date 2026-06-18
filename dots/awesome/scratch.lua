local awful = require("awful")
local gears = require("gears")

local client = client

local scratch = {}

local SCRATCH_CLASS = "scratchterm"

function scratch.toggle()
	local c = nil
	local s = awful.screen.focused()

	for _, cl in ipairs(client.get()) do
		if cl.valid and cl.class == SCRATCH_CLASS then
			c = cl
			break
		end
	end

	if c then
		local on_current_tag = false
		for _, t in ipairs(c:tags()) do
			if t == s.selected_tag then
				on_current_tag = true
				break
			end
		end

		if on_current_tag and not c.minimized then
			c.minimized = true
		else
			c.minimized = false
			if not on_current_tag then
				c:move_to_tag(s.selected_tag)
			end
			awful.placement.centered(c)
			c:emit_signal("request::activate", "scratch.toggle", { raise = true })
		end
	else
		awful.spawn("kitty --class " .. SCRATCH_CLASS .. " fish", {
			tag = s.selected_tag,
		}, function (clt)
			awful.placement.centered(clt)
		end)
	end
end

function scratch.init()
	table.insert(awful.rules.rules, 1, {
		rule = { class = SCRATCH_CLASS },
		properties = {
			floating = true,
			ontop = true,
			skip_taskbar = true,
			titlebars_enabled = false,
		},
		callback = function(c)
			c.ontop = true
			c.skip_taskbar = true
			gears.timer.start_new(0, function()
				if c.valid then
					local geo = c.screen.geometry
					c:geometry({
						width = math.floor(geo.width * 0.7),
						height = math.floor(geo.height * 0.6),
					})
					awful.placement.centered(c)
				end
			end)
		end,
	})
end

return scratch
