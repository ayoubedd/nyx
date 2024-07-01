{ pkgs, ... }:
let
  gen_floating_rule = { criteria, height, width }:
    [{
      inherit criteria;
      command = "floating enable, resize set ${toString width} ${toString height}";
    }];
in
{
  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    wrapperFeatures = {
      gtk = true;
      base = true;
    };
  };


  wayland.windowManager.sway.config =
    let
      mod = "Mod4";
      left = "h";
      right = "l";
      up = "k";
      down = "j";

      firefox = "${pkgs.firefox}/bin/firefox";
      yazi = "${pkgs.yazi}/bin/yazi";
      cliphist = "${pkgs.cliphist}/bin/cliphist";
      wofi = "${pkgs.wofi}/bin/wofi";
      slurp = "${pkgs.slurp}/bin/slurp";
      grim = "${pkgs.grim}/bin/grim";
      swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
      wl-color-picker = "${pkgs.wl-color-picker}/bin/wl-color-picker";
      term = "${pkgs.alacritty}/bin/alacritty";
      swayidle = "${pkgs.swayidle}/bin/swayidle";
      waybar = "${pkgs.waybar}/bin/waybar";
      swaymsg = "${pkgs.sway}/bin/swaymsg";
      sway = "${pkgs.sway}/bin/sway";
      wl-clipboard = "${pkgs.wl-clipboard}";
      wl-copy = "${wl-clipboard}/bin/wl-copy";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      pactl = "${pkgs.pulseaudio}/bin/pactl";
      brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
      wofi-emoji = "${pkgs.wofi-emoji}/bin/wofi-emoji";

      launcher = "~/.local/bin/app_launcher";
      execmd = "~/.local/bin/execmd";
      dragdrop = "~/.local/bin/dragdrop";
      window_picker = "~/.local/bin/window_picker";
      action = "~/.local/bin/sway_action";

      floating_term = "${term} --class floating-alacritty --title 'Floating Alacritty'";
      file_manager = "${term} --class floating-alacritty --title '${yazi}' -e 'yazi'";
      clipboard_mngr = "${cliphist} list | ${wofi} -d | ${cliphist} decode | ${wl-copy}";

      color_picker = "${wl-color-picker} clipboard";
      emoji_picker = "${wofi-emoji}";
      lock_screen = "${swaylock} -f";
      snaparea = "${grim} -g \"$(${slurp})\" - | tee ~/Pictures/Screenshots/$(date +%Y%m%d_%Hh%Mm%Ss)_area.png | ${wl-copy} -t 'image/png'";
      snapfull = "${grim} -g \"$(${slurp} -o)\" - | tee ~/Pictures/Screenshots/$(date +%Y%m%d_%Hh%Mm%Ss)_full.png | ${wl-copy} -t 'image/png'";

      # Sound;
      volume_up = "${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
      volume_down = "${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
      volume_mute_toggle = "${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
      player_play_toggle = "${playerctl} play-pause";
      player_next = "${playerctl} next";
      player_prev = "${playerctl} previous";

      # Screen;
      screen_brightness_up = "${brightnessctl} set +5% && notify-send \"Brightness\" \"Brightness: $(brightnessctl | grep -Eo '[0-9]+%')\"";
      screen_brightness_down = "${brightnessctl} set 5%- && notify-send \"Brightness\" \"Brightness: $(brightnessctl | grep -Eo '[0-9]+%');\"";

      wallpaper = "~/Pictures/Wallpapers/wallpaper.png";

      font_name = "Cantarell Bold";
      font_size = 12;
    in
    {
      modifier = mod;
      inherit up down right left;

      terminal = "${term}";

      bars = [ ];
      assigns = {
        # "1" = [ { app_id = "alacritty"; } ];
        "2" = [{ app_id = "firefox"; }];
        "3" = [{ app_id = "neovide"; }];
        "5" = [{ app_id = "org.qbittorrent.qBittorrent"; }];
      };

      defaultWorkspace = "1";

      output = {
        eDP-1 = {
          # bg = "~/path/to/background.png fill";
          scale = "2";
          render_bit_depth = "10";
          adaptive_sync = "on";
        };

      };

      seat = {
        "*" = {
          hide_cursor = "when-typing enable";
        };
      };

      input = {
        "type:touchpad" = {
          dwt = "enabled";
          tap = "enabled";
          natural_scroll = "enabled";
          middle_emulation = "enabled";
          pointer_accel = "0.4";
        };

        "type:mouse" = {
          accel_profile = "flat";
          pointer_accel = "0.1";
        };

        "type:keyboard" = {
          xkb_capslock = "disabled";
          xkb_numlock = "enabled";
          repeat_delay = "300";
          repeat_rate = "30";
          xkb_layout = "us";
        };
      };

      keybindings = {
        "${mod}+Return" = "exec ${term}";
        "${mod}+Shift+Return" = "exec ${floating_term}";
        "${mod}+Shift+f" = "exec exec ${file_manager}";
        "${mod}+Shift+e" = "exec exec $execmd";
        "${mod}+Alt+l" = "exec ${lock_screen}";
        "${mod}+Shift+m" = "exec ${emoji_picker}";
        "${mod}+Shift+c" = "exec ${color_picker}";
        "${mod}+Shift+v" = "exec ${clipboard_mngr}";
        "${mod}+x" = "exec ${action}";
        "${mod}+w" = "exec ${window_picker}";
        "${mod}+d" = "exec ${launcher}";
        "${mod}+Shift+d" = "exec ${dragdrop}";

        # Movement
        "${mod}+${left}" = "focus left";
        "${mod}+${down}" = "focus down";
        "${mod}+${up}" = "focus up";
        "${mod}+${right}" = "focus right";

        # Move the focused window with the same, but add Shift
        "${mod}+Shift+${left}" = "move left";
        "${mod}+Shift+${down}" = "move down";
        "${mod}+Shift+${up}" = "move up";
        "${mod}+Shift+${right}" = "move right";

        # Layout Keybinds
        "${mod}+f" = "fullscreen";
        "${mod}+Shift+q" = "kill";
        "${mod}+Shift+r" = "reload";
        "${mod}+a" = "focus parent";
        "${mod}+e" = "layout toggle all";
        "${mod}+space" = "focus mode_toggle";
        "${mod}+Tab" = "workspace back_and_forth";
        "${mod}+Shift+space" = "floating toggle";

        # Switch to workspace
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+Ctrl+l" = "workspace next";
        "${mod}+Ctrl+k" = "workspace next";
        "${mod}+Ctrl+j" = "workspace prev";
        "${mod}+Ctrl+h" = "workspace prev";

        # Move focused window to workspace
        "${mod}+Shift+1" = "move container to workspace number 1, workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2, workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3, workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4, workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5, workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6, workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7, workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8, workspace number 8";

        # Multimedia
        "XF86AudioRaiseVolume" = "exec ${volume_up}";
        "XF86AudioLowerVolume" = "exec ${volume_down}";
        "XF86AudioMute" = "exec  ${volume_mute_toggle}";
        "XF86AudioPlay" = "exec ${player_play_toggle}";
        "XF86AudioNext" = "exec ${player_next}";
        "XF86AudioPrev" = "exec ${player_prev}";

        # Brightness controls
        "XF86MonBrightnessUp" = "exec ${screen_brightness_up}";
        "XF86MonBrightnessDown" = "exec ${screen_brightness_down}";


        "${mod}+p" = "mode \"snap\"";
        "${mod}+r" = "mode \"resize\"";
      };

      modes = {
        resize = {
          Down = "resize grow height 10 px";
          Escape = "mode default";
          Left = "resize shrink width 10 px";
          Return = "mode default";
          Right = "resize grow width 10 px";
          Up = "resize shrink height 10 px";
          h = "resize shrink width 10 px";
          j = "resize grow height 10 px";
          k = "resize shrink height 10 px";
          l = "resize grow width 10 px";
        };

        snap = {
          a = "mode default, exec ${snaparea}";
          f = "mode default, exec ${snapfull}";
        };
      };

      fonts = {
        names = [ "Cantarell Bold" "Noto Sans" ]; # use gnome font
        # style = "";
        size = 12.0;
      };

      gaps = {
        smartBorders = "on";
      };

      window.titlebar = false;
      window.border = 2;
      window.commands = [
        {
          command = "inhibit_idle focus";
          criteria = {
            app_id = "mpv";
          };
        }
        {
          command = "inhibit_idle focus";
          criteria = {
            app_id = "firefox";
          };
        }
      ]
      ++ (gen_floating_rule { criteria.app_id = ".blueman-manager-wrapped"; width = 700; height = 500; })
      ++ (gen_floating_rule { criteria.app_id = "pavucontrol"; width = 700; height = 500; })
      ++ (gen_floating_rule { criteria.app_id = "floating-alacritty"; width = 900; height = 600; })
      ++ (gen_floating_rule { criteria.title = ".*Bitwarden.*"; width = 350; height = 600; })
      ++ (gen_floating_rule { criteria.app_id = "nm-connection-editor"; width = 700; height = 500; })
      ++ (gen_floating_rule { criteria.app_id = "seahorse"; width = 900; height = 700; })
      ++ (gen_floating_rule { criteria.app_id = "org.gnome.Nautilus"; width = 900; height = 700; });



      startup = [
        { command = "${cliphist} wipe"; }
        { command = "${firefox}"; }
        { command = "${waybar}"; }
        {
          command = "systemctl --user restart kanshi.service";
          always = true;
        }
      ];
    };

  # wayland.windowManager.sway.extraConfigEarly = '''';
  wayland.windowManager.sway.extraSessionCommands = ''
    export QT_QPA_PLATFORM=wayland
    export QT_QPA_PLATFORMTHEME=qt6ct
    export QT_PLATFORM_PLUGIN=qt6ct
    export QT_PLATFORMTHEME=qt6ct

    export CLUTTER_BACKEND=wayland
    export SDL_VIDEODRIVER=wayland
    export _JAVA_AWT_WM_NONREPARENTING=1
    export GDK_BACKEND=wayland

    export WLR_DRM_NO_MODIFIERS=1
    export XDG_CURRENT_DESKTOP=sway

    export MOZ_ENABLE_WAYLAND=1
    export MOZ_WAYLAND_USE_VAAPI=1
    export MOZ_DISABLE_RDD_SANDBOX=1

    export LIBVA_DRIVER_NAME=iHD
    export VDPAU_DRIVER=va_gl

    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    export _JAVA_AWT_WM_NONREPARENTING=1

    # export WLR_RENDERER=vulkan
  '';

}
