local mod = "SUPER"
local terminal = "alacritty"
local file_manager = "thunar"
local browser = "librewolf"

local left = "h"
local right = "l"
local up = "k"
local down = "j"
local snapfull =
	"grim -g \"$(slurp -o)\" - | tee ~/Pictures/Screenshots/$(date +%Y%m%d_%Hh%Mm%Ss)_full.png | wl-copy -t 'image/png'"
local snaparea =
	"grim -g \"$(slurp)\" - | tee ~/Pictures/Screenshots/$(date +%Y%m%d_%Hh%Mm%Ss)_area.png | wl-copy -t 'image/png'"

hl.config({
	dwindle = {
		preserve_split = true,
	},

	general = {
		gaps_out = 2,
		gaps_in = 2,
		layout = "dwindle",
	},

	decoration = {
		blur = {
			enabled = false,
		},
		shadow = {
			enabled = false,
		},
		rounding = 5,
		dim_inactive = true,
		dim_strength = 0.5,
	},

	cursor = {
		hide_on_key_press = true,
		no_hardware_cursors = true,
	},

	input = {
		kb_layout = "us",
		repeat_rate = 35,
		repeat_delay = 300,

		sensitivity = 0.2,
		accel_profile = "adaptive",
		force_no_accel = true,

		mouse_refocus = false,
		follow_mouse = 0,

		touchpad = {
			disable_while_typing = true,
			natural_scroll = true,
			tap_to_click = true,
			clickfinger_behavior = true,
		},
	},

	gestures = {
		workspace_swipe_forever = true,
	},

	animations = {
		enabled = true,
	},

	misc = {
		disable_hyprland_logo = true,
		force_default_wallpaper = 0,
		font_family = "Cantarell",
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
	},

	ecosystem = {
		no_update_news = true,
		no_donation_nag = false,
	},

	debug = {
		vfr = true,
	},
})

hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker | wl-copy"), { locked = true, repeating = true })

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
hl.bind(mod .. " + f", hl.dsp.window.fullscreen())
hl.bind(mod .. " + ALT + l", hl.dsp.exec_cmd("vicinae deeplink vicinae://launch/power/lock")) -- needs a fix
hl.bind(mod .. " + ALT + s", hl.dsp.exec_cmd("vicinae deeplink vicinae://launch/power/suspen")) -- needs a fix

hl.bind(mod .. " + d", hl.dsp.exec_cmd("vicinae toggle")) -- needs a fix
hl.bind(mod .. " + p", hl.dsp.exec_cmd("vicinae deeplink vicinae://launch/clipboard/history"))
hl.bind(mod .. " + w", hl.dsp.exec_cmd("vicinae deeplink vicinae://launch/wm/switch-windows"))
hl.bind(mod .. " + e", hl.dsp.exec_cmd("vicinae deeplink vicinae://launch/core/search-emojis"))

for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + SHIFT + Return", hl.dsp.exec_cmd(terminal .. " --class alacritty-float"))
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + SHIFT + F", hl.dsp.exec_cmd(file_manager))

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
	hl.bind("f", hl.dsp.exec_cmd(snapfull))
	hl.bind("a", hl.dsp.exec_cmd(snaparea))
end)

hl.define_submap("notifications", "reset", function()
	hl.bind("c", hl.dsp.exec_cmd("swaync-client -C"))
	hl.bind("t", hl.dsp.exec_cmd("swaync-client -t -sw"))
	hl.bind("d", hl.dsp.exec_cmd("swaync-client --toggle-dnd"))
end)

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -s -e4 -n2 set +5%"), { locked = true, repeating = true })
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl -s -e4 -n2 set 5%-"),
	{ locked = true, repeating = true }
)

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland,xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "auto",
	scale = 2,
	bitdepth = 8,
	vrr = 2,
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user restart pipewire pipewire.socket")
	hl.exec_cmd(
		"systemctl --user is-active xdg-desktop-portal-gtk.service && systemctl --user stop xdg-desktop-portal-gtk.service"
	)
	hl.exec_cmd(
		"systemctl --user is-active xdg-desktop-portal-hyprland.service && systemctl --user stop xdg-desktop-portal-hyprland.service"
	)
	hl.exec_cmd("systemctl --user restart xdg-desktop-portal.service")
	hl.exec_cmd("sleep 3 && pactl set-sink-mute @DEFAULT_SINK@ 1")
	hl.exec_cmd("sleep 5 && usbguard-notifies")
	hl.exec_cmd(browser)
	hl.exec_cmd(terminal)
end)

-- Window Rules
hl.window_rule({
	name = "librewolf",
	match = { class = "librewolf" },
	workspace = 2,
})

hl.window_rule({
	name = "alacritty",
	match = { class = "alacritty-float" },
	float = true,
	center = true,
	size = "900 600",
})

hl.window_rule({
	name = "blueman",
	match = { class = ".blueman-manager-wrapped" },
	size = "900 600",
	float = true,
})

hl.window_rule({
	name = "seahorse",
	match = { class = "org.gnome.seahorse.Application" },
	float = true,
	size = "900 700",
})

hl.window_rule({
	name = "thunar",
	match = { class = "[tT]hunar" },
	float = true,
	size = "900 600",
})
hl.window_rule({
	name = "network manager editor",
	match = { class = "nm-connection-editor" },
	float = true,
	size = "900 600",
})

hl.window_rule({
	name = "pavucontrol",
	match = { class = "org.pulseaudio.pavucontrol" },
	float = true,
	size = "900 600",
})

hl.window_rule({
	name = "zathuar",
	match = { class = "org.pwmt.zathura" },
	idle_inhibit = "focus",
})

hl.window_rule({
	name = "mpv",
	match = { class = "mpv" },
	idle_inhibit = "focus",
})

-- HDR support

-- hl.monitor({
-- 	output = "eDP-1",
-- 	mode = "preferred",
-- 	position = "auto",
-- 	scale = 2,
-- 	bitdepth = 10,
-- 	vrr = 2,
-- 	supports_hdr = 1,
-- 	cm = "hdredid",
-- 	sdr_min_luminance = 0,
-- 	sdr_max_luminance = 80,
-- 	sdrbrightness = 4,
-- 	sdrsaturation = 1,
-- })
--
-- hl.config({
-- 	render = {
-- 		new_render_scheduling = true,
-- 		cm_auto_hdr = 2,
-- 		use_fp16 = 2,
-- 	},
--
-- 	quirks = {
-- 		prefer_hdr = 1,
-- 	},
-- })
