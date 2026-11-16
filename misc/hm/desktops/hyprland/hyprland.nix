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
        before_sleep_cmd = "${loginctl} lock-session"; # lock before suspend.
        # Hyprland 0.55+ takes Lua for `dispatch` (the old `dispatch dpms on`
        # fails), and invalid dpms actions are silently ignored, so keep these
        # exactly "enable" / "disable".
        after_sleep_cmd = "${dpmsOn}"; # to avoid having to press a key twice to turn on the display.
      };

      listener = [
        {
          timeout = 150; # 2.5min.
          on-timeout = "${brightnessctl} -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
          on-resume = "${brightnessctl} -r"; # monitor backlight restore.
        }
        {
          timeout = 150; # 2.5min.
          on-timeout = "${brightnessctl} -sd tpacpi::kbd_backlight set 00"; # turn off keyboard backlight.
          on-resume = "${brightnessctl} -rd tpacpi::kbd_backlight"; # turn on keyboard backlight.
        }
        {
          timeout = 300; # 5min
          on-timeout = "${loginctl} lock-session"; # lock screen when timeout has passed
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
    settings = {
      max-gamma = 150;

      profile = [
        {
          time = "7:30";
          identity = true;
        }
        {
          time = "21:00";
          temperature = 4000;
        }
      ];
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
