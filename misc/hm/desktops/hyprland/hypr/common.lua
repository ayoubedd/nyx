hl.config({
	dwindle = {
		preserve_split = true,
	},

	render = {
		-- Don't switch a monitor to HDR / wide gamut when a fullscreen app asks
		-- for it (default 1). The displays run 8-bit, so the switch failed:
		-- mpv (gpu-next) playing 10-bit HDR video fullscreen went black with
		-- "wide color gamut is enabled but the display is not in 10-bit mode".
		-- mpv tone-maps HDR to SDR itself instead. (For real HDR output, see
		-- the commented 10-bit monitor rule in monitor.lua.)
		cm_auto_hdr = 0,
	},

	scrolling = {
		column_width = 0.49,
	},

	general = {
		-- Windows are 2 * gaps_in apart, so the top (bar side) gets the same
		-- 4px; the screen edges keep 2.
		gaps_out = { top = 4, right = 2, bottom = 2, left = 2 },
		gaps_in = 2,
		layout = "dwindle",
	},

	decoration = {
		-- Only affects translucent surfaces (e.g. the quickshell control center).
		blur = {
			enabled = true,
			size = 14,
			passes = 4, -- on battery quickshell drops this to 2 (services/PowerSaver.qml)
			noise = 0.02,
			vibrancy = 0.2,
			popups = false,
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
		-- no_hardware_cursors left at its default (2 = auto): the Iris Xe
		-- (i915) cursor plane works, and a software cursor makes every mouse
		-- move recomposite the screen.
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
		-- Let a restarted quickshell take over the lock if it crashes while locked.
		allow_session_lock_restore = true,
		-- Switching windows while one is fullscreen (Alt+Tab, Super+arrows,
		-- clicking a notification...): the newly focused window takes over
		-- fullscreen and the previous one goes back to tiling, so you stay in
		-- fullscreen mode instead of dropping out of it.
		on_focus_under_fullscreen = 1,
	},

	ecosystem = {
		no_update_news = true,
		no_donation_nag = false,
	},
	binds = {
		hide_special_on_workspace_change = true,
		-- Super+arrows move between windows even while one is fullscreen
		-- (otherwise they only jump between monitors).
		movefocus_cycles_fullscreen = true,
	},
})
