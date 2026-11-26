require("globals")

hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "auto",
	scale = 2,
	bitdepth = 8,
	vrr = 2,
	cm = "srgb",
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
	hl.exec_cmd("sleep 3 && uwsm app -- pactl set-sink-mute @DEFAULT_SINK@ 1")
	hl.exec_cmd("uwsm app -- " .. browser)
	hl.exec_cmd("uwsm app -- " .. terminal)
end)

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
