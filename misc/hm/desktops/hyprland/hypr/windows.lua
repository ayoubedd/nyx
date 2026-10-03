-- Window Rules
hl.window_rule({
	name = "librewolf",
	match = { class = "librewolf" },
	workspace = 2,
})

hl.window_rule({
	name = "kitty",
	match = { class = "floating-terminal" },
	float = true,
	center = true,
	size = "900 600",
})

hl.window_rule({
	name = "blueman",
	match = { class = "blueman-manager" },
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
	name = "Screen Share Dialog",
	match = { title = "Select what to share" },
	float = false,
	size = "600 200",
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
