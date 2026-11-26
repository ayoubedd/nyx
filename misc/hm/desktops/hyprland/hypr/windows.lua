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

-- Bitwarden extension popout. Browser extension windows open titled just
-- "LibreWolf" (or "Mozilla Firefox") and only later rename themselves to
-- "Extension: (Bitwarden Password Manager) - ... — LibreWolf".
--
-- Whether a window floats is decided from window rules before any Lua hook
-- can run (window.open_early is already too late), and at that point the
-- popout is indistinguishable from any new browser window. So it's inverted:
-- every new browser window opens floating at the popout's size, and Lua sends
-- it back to tiling as soon as it's known not to be the popout:
-- - the only browser window (a fresh launch): tiled right away on open;
-- - otherwise: once its real title arrives and it isn't Bitwarden.
local browser_classes = { librewolf = "LibreWolf", firefox = "Mozilla Firefox" }
local popout_size = "420 640"

-- Static: decided once at map time, from the initial title.
hl.window_rule({
	name = "browser popout",
	match = { class = "^(librewolf|firefox)$", initial_title = "^(LibreWolf|Mozilla Firefox)$" },
	float = true,
	center = true,
	size = popout_size,
	suppress_event = "maximize fullscreen",
})

-- Dynamic: follows the current title, so it covers the popout while its
-- title is still bare and once it's Bitwarden, and drops off by itself for
-- ordinary windows. Locks the size and turns animations off.
hl.window_rule({
	name = "browser popout lock",
	match = {
		class = "^(librewolf|firefox)$",
		title = "^(LibreWolf|Mozilla Firefox)$|^Extension: \\(Bitwarden",
	},
	min_size = popout_size,
	max_size = popout_size,
	no_anim = true,
})

hl.on("window.open", function(w)
	local name = browser_classes[w.class]
	if not name or w.initial_title ~= name then
		return
	end

	local only_window = true
	for _, other in ipairs(hl.get_windows({ class = w.class })) do
		if other.address ~= w.address then
			only_window = false
			break
		end
	end
	if only_window then
		hl.dispatch(hl.dsp.window.float({ action = "unset", window = w }))
		return
	end

	-- Decide once: on the first real title, or after a timeout for a window
	-- that keeps a bare title (blank new window). All listeners are dropped
	-- when decided or when the window closes, so none outlive the window.
	local title_sub, close_sub, timeout
	local function finish()
		if title_sub then
			title_sub:remove()
		end
		if close_sub then
			close_sub:remove()
		end
		if timeout then
			timeout:set_enabled(false)
		end
		title_sub, close_sub, timeout = nil, nil, nil
	end

	title_sub = hl.on("window.title", function(tw)
		if tw.address ~= w.address then
			return
		end
		local title = tw.title
		if title == "" or title == name or title:match("^about:") then
			return
		end
		finish()

		if title:match("^Extension:") and title:find("Bitwarden", 1, true) then
			hl.dispatch(hl.dsp.focus({ window = tw }))
		else
			hl.dispatch(hl.dsp.window.float({ action = "unset", window = tw }))
		end
	end)

	close_sub = hl.on("window.close", function(cw)
		if cw.address == w.address then
			finish()
		end
	end)

	-- The Bitwarden popout renames itself within moments; anything still
	-- bare after this is an ordinary (blank) browser window: tile it.
	timeout = hl.timer(function()
		if title_sub then
			finish()
			hl.dispatch(hl.dsp.window.float({ action = "unset", window = w }))
		end
	end, { timeout = 3000, type = "oneshot" })
end)

-- Layer Rules
-- Frosted-glass blur behind the quickshell control center and notification
-- popups. ignore_alpha skips the fully transparent parts of the surface.
hl.layer_rule({
	name = "quickshell-glass",
	match = { namespace = "^nyx-(control-center|notifications|osd|polkit|overview|nowplaying)$" },
	blur = true,
	ignore_alpha = 0.1,
})
