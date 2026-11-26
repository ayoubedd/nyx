-- Default animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 3.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "fadeSwitch", enabled = false })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = false })

-- Switching windows while one is fullscreen is instant (no animation).
--
-- With misc.on_focus_under_fullscreen = 1 (common.lua) the newly focused
-- window takes over fullscreen and the old one drops back into the tiling.
-- Hyprland does that hand-over before it emits window.active. A per-window
-- no_anim isn't enough (the hand-over also starts workspace-level fullscreen
-- fades, which ignore it), so animations are switched off globally for a
-- moment instead: the animation loop checks animations.enabled on every
-- frame, so the transition snaps to its end before its first frame. The
-- previous value is restored afterwards (quickshell's PowerSaver turns
-- animations off on battery; then there's nothing to do here anyway).
-- Toggling fullscreen and switching between ordinary windows keep their
-- animations.
local last_active = nil
local restore_anims = nil

local function animations_enabled()
	local ok, v = pcall(hl.get_config, "animations.enabled")
	if not ok or v == nil then
		return false
	end
	if type(v) == "table" then
		v = v.value
	end
	return v == true or v == 1
end

hl.on("window.active", function(w)
	local prev = last_active
	last_active = w
	if w == nil or prev == nil or prev.address == w.address then
		return
	end
	if (w.fullscreen or 0) == 0 then
		return
	end
	-- Already off (battery / power saver), or a switch is already pending.
	if restore_anims == nil and not animations_enabled() then
		return
	end

	if restore_anims then
		restore_anims:set_enabled(false)
	end
	hl.config({ animations = { enabled = false } })
	restore_anims = hl.timer(function()
		restore_anims = nil
		hl.config({ animations = { enabled = true } })
	end, { timeout = 400, type = "oneshot" })
end)
