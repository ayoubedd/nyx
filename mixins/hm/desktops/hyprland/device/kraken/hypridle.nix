{ pkgs, lib, ... }:
let
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  pidof = "${pkgs.procps}/bin/pidof";
in {
  # overidding the default config
  services.hypridle = lib.mkForce {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${pidof} hyprlock || ${hyprlock}";
        before_sleep_cmd = "${loginctl} lock-session"; # lock before suspend.
        after_sleep_cmd =
          "${hyprctl} dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        ignore_dbus_inhibit = false;
      };

      listener = [
        {
          timeout = 150; # 2.5min.
          on-timeout =
            "${brightnessctl} -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
          on-resume = "${brightnessctl} -r"; # monitor backlight restore.
        }
        {
          timeout = 150; # 2.5min.
          on-timeout =
            "${brightnessctl} -sd tpacpi::kbd_backlight set 0"; # turn off keyboard backlight.
          on-resume =
            "${brightnessctl} -rd tpacpi::kbd_backlight"; # turn on keyboard backlight.
        }
        {
          timeout = 300; # 5min
          on-timeout =
            "${loginctl} lock-session"; # lock screen when timeout has passed
        }
        {
          timeout = 330; # 5.5min
          on-timeout =
            "${hyprctl} dispatch dpms off"; # screen off when timeout has passed
          on-resume =
            "${hyprctl} dispatch dpms on"; # screen on when activity is detected after timeout has fired.
        }
      ];
    };
  };
}
