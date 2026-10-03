require("globals")

hl.bind(mod .. " + SHIFT + C", exec_cmd("hyprpicker | wl-copy"), { locked = true, repeating = true })

hl.bind(mod .. " + " .. left, hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + " .. right, hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + " .. up, hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + " .. down, hl.dsp.focus({ direction = "down" }))

hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(mod .. " + q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + q", hl.dsp.window.kill())
hl.bind(mod .. " + SHIFT + Space", hl.dsp.window.float())
hl.bind(mod .. " + f", hl.dsp.window.fullscreen({ layout_aware = false }))
hl.bind(mod .. " + ALT + l", exec_cmd("vicinae deeplink vicinae://launch/power/lock")) -- needs a fix
hl.bind(mod .. " + ALT + s", exec_cmd("vicinae deeplink vicinae://launch/power/suspend")) -- needs a fix

hl.bind(mod .. " + d", exec_cmd("vicinae toggle")) -- needs a fix
hl.bind(mod .. " + p", exec_cmd("vicinae deeplink vicinae://launch/clipboard/history"))
hl.bind(mod .. " + w", exec_cmd("vicinae deeplink vicinae://launch/wm/switch-windows"))
hl.bind(mod .. " + e", exec_cmd("vicinae deeplink vicinae://launch/core/search-emojis"))
hl.bind(
	mod .. " + s",
	exec_cmd("vicinae deeplink vicinae://launch/@rastsislaux/store.vicinae.pulseaudio/outputDevices")
)

for i = 1, 10 do
	 local magic_workspaces = { "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" }
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))

  hl.workspace_rule({ workspace = i, layout = "scrolling" })

	hl.bind("CTRL + SUPER + " .. key, hl.dsp.workspace.toggle_special(magic_workspaces[i]))
	hl.workspace_rule({ workspace = "special:" .. magic_workspaces[i], layout = "scrolling" })
	hl.bind("CTRL + SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = "special:" .. magic_workspaces[i] }))
end

hl.bind(mod .. " + Return", exec_cmd("" .. terminal))
hl.bind(mod .. " + SHIFT + Return", exec_cmd("" .. terminal_floating))
hl.bind(mod .. " + SHIFT + B", exec_cmd("" .. browser))
hl.bind(mod .. " + SHIFT + F", exec_cmd("" .. file_manager))

hl.bind("ALT + R", hl.dsp.submap("resize"))
hl.bind("ALT + M", hl.dsp.submap("move"))
hl.bind("ALT + S", hl.dsp.submap("snapshot"))
hl.bind("ALT + N", hl.dsp.submap("notifications"))

hl.define_submap("resize", function()
	hl.bind(right, hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
	hl.bind(left, hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
	hl.bind(up, hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
	hl.bind(down, hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })

	hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.define_submap("move", function()
	hl.bind(right, hl.dsp.window.move({ x = 10, y = 0, relative = true }), { repeating = true })
	hl.bind(left, hl.dsp.window.move({ x = -10, y = 0, relative = true }), { repeating = true })
	hl.bind(up, hl.dsp.window.move({ x = 0, y = -10, relative = true }), { repeating = true })
	hl.bind(down, hl.dsp.window.move({ x = 0, y = 10, relative = true }), { repeating = true })

	hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.define_submap("snapshot", "reset", function()
	-- Set repeating binds for resizing the active window.
	hl.bind("f", exec_cmd(snapfull))
	hl.bind("a", exec_cmd(snaparea))
	hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.define_submap("notifications", "reset", function()
	hl.bind("c", exec_cmd("swaync-client -C"))
	hl.bind("t", exec_cmd("swaync-client -t -sw"))
	hl.bind("d", exec_cmd("swaync-client --toggle-dnd"))
	hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioMute", exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind(
	"XF86AudioMicMute",
	exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", exec_cmd("brightnessctl -s -e4 -n2 set +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", exec_cmd("brightnessctl -s -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", exec_cmd("playerctl previous"), { locked = true })
