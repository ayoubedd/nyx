mod = "SUPER"
terminal = "kitty"
terminal_floating = "kitty --class floating-terminal"
file_manager = "thunar"
browser = "librewolf"

left = "h"
right = "l"
up = "k"
down = "j"
snapfull =
	"grim -g \"$(slurp -o)\" - | tee ~/Pictures/Screenshots/$(date +%Y%m%d_%Hh%Mm%Ss)_full.png | wl-copy -t 'image/png'"
snaparea =
	"grim -g \"$(slurp)\" - | tee ~/Pictures/Screenshots/$(date +%Y%m%d_%Hh%Mm%Ss)_area.png | wl-copy -t 'image/png'"

function exec_cmd(cmd)
	return hl.dsp.exec_cmd("uwsm app -- " .. cmd)
end
