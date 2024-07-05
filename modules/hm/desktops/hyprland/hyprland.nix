{ pkgs, ... }:

let
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";

  volume_up = "${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
  volume_down = "${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
  volume_mute_toggle = "${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
  player_play_toggle = "${playerctl} play-pause";
  player_next = "${playerctl} next";
  player_prev = "${playerctl} previous";

  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  pidof = "${pkgs.procps}/bin/pidof";

  notify-send = "${pkgs.libnotify}/bin/notify-send";
  screen_brightness_up = "${brightnessctl} set +5% && ${notify-send} \"Brightness\" \"Brightness: $(brightnessctl | grep -Eo '[0-9]+%')\"";
  screen_brightness_down = "${brightnessctl} set 5%- && ${notify-send} \"Brightness\" \"Brightness: $(brightnessctl | grep -Eo '[0-9]+%')\"";

  wofi = "${pkgs.wofi}/bin/wofi";

  waybar = "${pkgs.waybar}/bin/waybar";
  wl-clip-persist = "${pkgs.wl-clip-persist}/bin/wl-clip-persist";

  homescreen_img = ../../../../media/images/homescreen.png;
  lockscreen_img = ../../../../media/images/lockscreen.png;
in
{
  wayland.windowManager.hyprland.enable = true;

  wayland.windowManager.hyprland.settings =
    {
      "$mod" = "SUPER";
      "$terminal" = "${pkgs.alacritty}/bin/alacritty";
      "$file_manager" = "${pkgs.yazi}/bin/yazi";

      exec-once = [
        "${waybar}"
        "${wl-clip-persist} --clipboard both"
      ];

      bindm = [
        "ALT,mouse:272,resizewindow"
        "ALT_SHIFT,mouse:272,movewindow"
      ];

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod_SHIFT, q, killactive,"
        "$mod, M, exit,"
        "$mod_SHIFT, space, togglefloating,"
        "$mod, d, exec, $menu"

        "$mod, l, movefocus, r"
        "$mod, h, movefocus, l"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        "$mod SHIFT, l, moveactive, 30 0"
        "$mod SHIFT, h, moveactive, -30 0"
        "$mod SHIFT, k, moveactive, 0 -30"
        "$mod SHIFT, j, moveactive, 0 30"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod_SHIFT, l, exec, ${loginctl} lock-session"
        "$mod, d, exec, ${wofi}"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        "$mod, f, fullscreen, 0"

        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        # Multimedia
        ",XF86AudioRaiseVolume, exec, ${volume_up}"
        ",XF86AudioLowerVolume, exec, ${volume_down}"
        ",XF86AudioMute, exec, ${volume_mute_toggle}"
        ",XF86AudioPlay, exec, ${player_play_toggle}"
        ",XF86AudioNext, exec, ${player_next}"
        ",XF86AudioPrev, exec, ${player_prev}"

        # Brightness controls
        ",XF86MonBrightnessUp, exec, ${screen_brightness_up}"
        ",XF86MonBrightnessDown, exec, ${screen_brightness_down}"
      ];

      general = {
        gaps_out = 0;
        layout = "dwindle";
      };

      monitor = [
        "eDP-1,preferred,auto,2,bitdepth,10"
      ];

      decoration = {
        blur = {
          enabled = false;
        };
        drop_shadow = false;
        rounding = 5;
      };

      misc.vfr = true;

      animations = {
        enabled = true;
      };

      input = {
        kb_layout = "us";
        repeat_rate = 35;
        repeat_delay = 300;

        sensitivity = 0.1;
        accel_profile = "flat";
        force_no_accel = true;
        natural_scroll = true;

        mouse_refocus = false;
        follow_mouse = 0;

        touchpad = {
          disable_while_typing = true;
          natural_scroll = true;
          tap-to-click = true;
        };
      };

      # plugins = [ ];
    };


  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      preload = toString homescreen_img;
      wallpaper = ",${toString homescreen_img}";
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${pidof} hyprlock || ${hyprlock}";
        before_sleep_cmd = "${loginctl} lock-session"; # lock before suspend.
        after_sleep_cmd = "${hyprctl} dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        ignore_dbus_inhibit = false;
      };

      listener = [
        {
          timeout = 150; # 2.5min.
          on-timeout = "${brightnessctl} -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
          on-resume = "${brightnessctl} -r"; # monitor backlight restore.
        }
        {
          timeout = 150; # 2.5min.
          on-timeout = "${brightnessctl} -sd tpacpi::kbd_backlight set 0"; # turn off keyboard backlight.
          on-resume = "${brightnessctl} -rd tpacpi::kbd_backlight"; # turn on keyboard backlight.
        }
        {
          timeout = 300; # 5min
          on-timeout = "${loginctl} lock-session"; # lock screen when timeout has passed
        }
        {
          timeout = 330; # 5.5min
          on-timeout = "${hyprctl} dispatch dpms off"; # screen off when timeout has passed
          on-resume = "${hyprctl} dispatch dpms on"; # screen on when activity is detected after timeout has fired.
        }
        {
          timeout = 1800; # 30min
          on-timeout = "${systemctl} suspend"; # suspend pc
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      grace = 10;
      background = {
        path = toString lockscreen_img;
      };
    };
  };
}
