hl.config({
	dwindle = {
		preserve_split = true,
	},

	scrolling = {
		column_width = 0.49,
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
		font_family = "Noto Sans Mono",
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
	},

	ecosystem = {
		no_update_news = true,
		no_donation_nag = false,
	},
	binds = {
		hide_special_on_workspace_change = true,
	},
})
