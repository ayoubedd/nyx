{
  pkgs,
  config,
  ...
}:
let
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  pidof = "${pkgs.procps}/bin/pidof";
  qs = "${config.programs.quickshell.package}/bin/qs";
  dpmsOn = "${hyprctl} dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
  dpmsOff = "${hyprctl} dispatch 'hl.dsp.dpms({ action = \"disable\" })'";

  # Keyboard backlight level kept across idle-off and suspend. The firmware
  # resets it on resume (and brightnessctl -s/-r's single save slot got
  # overwritten when an idle-off and a suspend overlapped), so one saved
  # level in $XDG_RUNTIME_DIR: `off` / `save` record it unless already
  # recorded, `restore` puts it back and forgets it.
  kbdBacklight = pkgs.writeShellScript "nyx-kbd-backlight" ''
    kbd=tpacpi::kbd_backlight
    state="''${XDG_RUNTIME_DIR:-/tmp}/nyx-kbd-level"
    case "$1" in
      off)
        [ -e "$state" ] || ${brightnessctl} -d "$kbd" get > "$state"
        ${brightnessctl} -qd "$kbd" set 0
        ;;
      save)
        [ -e "$state" ] || ${brightnessctl} -d "$kbd" get > "$state"
        ;;
      restore)
        # After a resume the firmware applies its own level a moment later.
        [ "$2" = after-sleep ] && sleep 1
        if [ -e "$state" ]; then
          ${brightnessctl} -qd "$kbd" set "$(cat "$state")"
          rm -f "$state"
        fi
        ;;
    esac
  '';
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    systemd.enable = false;
  };

  home.file.".config/hypr" = {
    source = ./hypr;
    recursive = true;
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # Quickshell lock screen; falls back to hyprlock if quickshell isn't running.
        lock_cmd = "${qs} -c nyx ipc call lock lock || ${pidof} hyprlock || ${hyprlock}";
        # Remember the keyboard backlight, then lock before suspend.
        before_sleep_cmd = "${kbdBacklight} save; ${loginctl} lock-session";
        # Hyprland 0.55+ takes Lua for `dispatch` (the old `dispatch dpms on`
        # fails), and invalid dpms actions are silently ignored, so keep these
        # exactly "enable" / "disable".
        # Display on (avoids pressing a key twice), keyboard backlight back.
        after_sleep_cmd = "${dpmsOn}; ${kbdBacklight} restore after-sleep";
      };

      listener = [
        {
          timeout = 150; # 2.5min.
          on-timeout = "${brightnessctl} -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
          on-resume = "${brightnessctl} -r"; # monitor backlight restore.
        }
        {
          timeout = 150; # 2.5min.
          on-timeout = "${kbdBacklight} off"; # keyboard backlight off (level remembered).
          on-resume = "${kbdBacklight} restore"; # and back.
        }
        {
          # Gentle fade to black over the last 15 s before locking
          # (quickshell overlays/IdleFade.qml); any input cancels it.
          timeout = 285;
          on-timeout = "${qs} -c nyx ipc call idlefade start 15";
          on-resume = "${qs} -c nyx ipc call idlefade cancel";
        }
        {
          timeout = 300; # 5min
          on-timeout = "${loginctl} lock-session"; # lock screen when timeout has passed
          on-resume = "${qs} -c nyx ipc call idlefade cancel"; # (also after unlocking)
        }
        {
          timeout = 330; # 5.5min
          on-timeout = "${dpmsOff}"; # screen off when timeout has passed
          on-resume = "${dpmsOn}"; # screen on when activity is detected after timeout has fired.
        }
        {
          timeout = 1800; # 30min
          on-timeout = "${systemctl} suspend"; # suspend pc
        }
      ];
    };
  };

  services.hyprsunset = {
    enable = true;
    # No profiles: the schedule (sunset/sunrise or custom times) is run by
    # quickshell (quickshell/config/services/NightLight.qml), which drives
    # hyprsunset through `hyprctl hyprsunset`.
    settings = {
      max-gamma = 150;
    };
  };

  services.wl-clip-persist = {
    enable = true;
    clipboardType = "both";
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };
      background = {
        path = "/home/${config.home.username}/Pictures/Wallpapers/lockscreen.png";
      };
    };
  };
}
