require("globals")

hl.bind(mod .. " + SHIFT + C", exec_cmd("hyprpicker | wl-copy"))

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
hl.bind(mod .. " + ALT + l", exec_cmd("loginctl lock-session")) -- -> hypridle lock_cmd (quickshell lock)
hl.bind(mod .. " + ALT + s", hl.dsp.exec_cmd("systemctl suspend"))

-- Launcher (quickshell launcher/Launcher.qml).
-- Shell binds use nyx() (globals.lua): quickshell GlobalShortcuts, no process
-- spawned per press. `qs -c nyx ipc call ...` still works from scripts.
hl.bind(mod .. " + d", nyx("launcher"))
hl.bind(mod .. " + p", nyx("launcher-clipboard"))
hl.bind(mod .. " + w", nyx("launcher-windows"))
hl.bind(mod .. " + e", nyx("launcher-emoji"))
-- Vim-style clipboard registers (quickshell overlays/RegisterPanel.qml):
-- Super+' opens the panel (a-z put, Shift+a-z store, 1-9 recent);
-- Super+Shift+' opens it ready to store the current clipboard.
hl.bind(mod .. " + apostrophe", nyx("registers"))
hl.bind(mod .. " + SHIFT + apostrophe", nyx("registers-store"))
-- Bar sound menu (outputs, inputs, per-app volume).
hl.bind(mod .. " + s", nyx("sound-menu"))

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
-- Screenshot overlay (quickshell Screenshot.qml). Shift+Print is a plain
-- slurp+grim fallback for when quickshell isn't running.
hl.bind("ALT + S", nyx("screenshot"))
hl.bind("Print", nyx("screenshot"))
hl.bind("SHIFT + Print", exec_cmd(snaparea))

-- Workspace overview with live window previews (quickshell Overview.qml).
hl.bind(mod .. " + Tab", nyx("overview"))

-- Alt+Tab window switcher (quickshell overlays/AltTab.qml): hold Alt, tap
-- Tab / Shift+Tab, release Alt to switch. The release bind is a backup for
-- the overlay's own key-release handling; non_consuming so Alt still reaches
-- apps, and a no-op when the switcher isn't open.
hl.bind("ALT + Tab", nyx("alttab-next"))
hl.bind("ALT + SHIFT + Tab", nyx("alttab-prev"))
hl.bind("ALT + Alt_L", nyx("alttab-commit"), { release = true, non_consuming = true })
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

hl.define_submap("notifications", "reset", function()
	hl.bind("c", nyx("notifications-clear"))
	hl.bind("t", nyx("notifications-toggle"))
	hl.bind("d", nyx("notifications-dnd"))
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
-- Toggles: no `repeating`, or holding the key flips mute on and off.
hl.bind("XF86AudioMute", exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
-- Linear 5% steps of the full range (no -e exponent curve), so steps are even
-- and match the percentage shown by the OSD / control center slider.
-- -n5 is a raw floor (brightnessctl ignores "%" there): ~1% of the x1's 504 max,
-- so the panel never goes fully black.
-- `qs ... osd brightness` shows the quickshell OSD (no-op if quickshell isn't running).
hl.bind(
	"XF86MonBrightnessUp",
	exec_cmd("brightnessctl -n5 set +5% && qs -c nyx ipc call osd brightness"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	exec_cmd("brightnessctl -n5 set 5%- && qs -c nyx ipc call osd brightness"),
	{ locked = true, repeating = true }
)

-- Requires playerctl
hl.bind("XF86AudioNext", exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", exec_cmd("playerctl previous"), { locked = true })
