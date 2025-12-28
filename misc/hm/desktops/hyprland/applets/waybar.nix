{ lib, pkgs, ... }:
let
  alacritty = "${pkgs.alacritty}/bin/alacritty";
  btop = "${pkgs.btop}/bin/btop";
  vicinae = "${pkgs.vicinae}/bin/vicinae";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  blueman = "${pkgs.blueman}/bin/blueman-manager";
in
{
  # depedent packges
  home.packages = with pkgs; [
    font-awesome
    noto-fonts
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        "layer" = "top";
        "position" = "top";
        "height" = 35;
        "spacing" = 5;

        "modules-left" = [
          "hyprland/workspaces"
          "cpu"
          "memory"
          "disk"
          "temperature"
          "battery"
        ];

        "modules-center" = [ "clock" ];
        "modules-right" = [
          "privacy"
          "network"
          "bluetooth"
          "backlight"
          "wireplumber"
          "idle_inhibitor"
          "tray"
          "custom/notification"
        ];

        "hyprland/workspaces" = {
          "format" = "{icon}";
          "on-click" = "activate";
          "icon-size" = 8;
          "sort-by-number" = true;
          "persistent-workspaces" = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
          };
        };

        "clock" = {
          "format" = "{:%a, %d %b, %H:%M}";
          "tooltip" = false;
        };

        "wireplumber" = {
          "format" = "{volume}%  {icon}";
          "format-muted" = "{volume}%   ";
          "tooltip-format" = "{volume}%";
          "on-click" = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "reverse-scrolling" = true;
          "max-volume" = 100;
          "scroll-step" = 5;
          "format-icons" = [
            ""
            ""
          ];
        };

        "battery" = {
          "bat" = "BAT0";
          "interval" = 60;
          "format" = "{icon} {time}";
          "tooltip-format" = "Capacity: {capacity}%, Power: {power}, Cycles: {cycles}";
          "states" = {
            "warning" = 30;
            "critical" = 15;
          };
          "format-icons" = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        "backlight" = {
          "device" = "intel_backlight";
          "format" = "{percent}% {icon}";
          "tooltip" = false;
          "format-icons" = [ "" ];
        };

        "cpu" = {
          "interval" = 5;
          "format" = "   {}%";
          "max-length" = 10;
          "on-click" = "${alacritty} --class=alacritty-float --command=${btop}";
          "tooltip" = false;
        };

        "memory" = {
          "interval" = 30;
          "format" = "   {used:0.1f}G";
          "on-click" = "${alacritty} --class=alacritty-float --command=${btop}";
          "tooltip" = false;
        };

        "disk" = {
          "format" = "  {percentage_used}%";
        };

        "temperature" = {
          "format" = "  {temperatureC}°C";
          "on-click" = "${alacritty} --class=alacritty-float --command=${btop}";
          "thermal-zone" = 5;
          "interval" = 5;
          "critical-threshold" = 80;
          "tooltip" = false;
        };

        "network" = {
          "interval" = 2;
          "interface" = "wlp0s20f3";
          "format-wifi" = "  {bandwidthDownBytes}      {bandwidthUpBytes}    {essid}  ";
          "on-click" = "${vicinae} vicinae://extensions/dagimg-dot/wifi-commander/manage-saved-networks";
          "format-ethernet" = "  {bandwidthDownBytes}      {bandwidthUpBytes}    {ipaddr}/{cidr} 󰊗";
          "format-disconnected" = "Disconnected"; # An empty format will hide the module.
          "tooltip-format" = "{ifname} via {gwaddr} 󰊗";
          "tooltip-format-wifi" = "Signal Strength ({signalStrength}%)  ";
          "tooltip-format-ethernet" = "{ifname} ";
          "tooltip-format-disconnected" = "Disconnected";
        };

        bluetooth = {
          format = "";
          on-click = "${blueman}";
          "format-connected" = " {device_alias}";
          "format-connected-battery" = "{device_battery_percentage}%   {device_alias}  ";
        };

        "tray" = {
          "icon-size" = 16;
          "spacing" = 14;
        };

        "custom/notification" = {
          "tooltip" = false;
          "format" = "{icon}";
          "format-icons" = {
            "notification" = "<span foreground='red'><sup></sup></span>";
            "none" = "";
            "dnd-notification" = "<span foreground='red'><sup></sup></span>";
            "dnd-none" = "";
            "inhibited-notification" = "<span foreground='red'><sup></sup></span>";
            "inhibited-none" = "";
            "dnd-inhibited-notification" = "<span foreground='red'><sup></sup></span>";
            "dnd-inhibited-none" = "";
          };
          "return-type" = "json";
          "exec-if" = "which swaync-client";
          "exec" = "swaync-client -swb";
          "on-click" = "swaync-client -t -sw";
          "on-click-right" = "swaync-client -d -sw";
          "escape" = true;
        };

        "privacy" = {
          "icon-spacing" = 8;
          "icon-size" = 14;
          "transition-duration" = 250;
          "modules" = [
            {
              "type" = "screenshare";
              "tooltip" = true;
              "tooltip-icon-size" = 24;
            }
            {
              "type" = "audio-out";
              "tooltip" = true;
              "tooltip-icon-size" = 24;
            }
            {
              "type" = "audio-in";
              "tooltip" = true;
              "tooltip-icon-size" = 24;
            }
          ];
          "ignore-monitor" = true;
        };

        "idle_inhibitor" = {
          "format" = "{icon}";
          "format-icons" = {
            "activated" = "";
            "deactivated" = "";
          };
        };
      };
    };

    style = /* scss */ ''
      @define-color foreground #eeeeee;
      @define-color foreground-inactive #aaaaaa;
      @define-color background #000000;

      * {
        font-family:
          "Noto Sans", "Font Awesome 7 Free", "Font Awesome 7 Brands",
          "Font Awesome 6 Free", "Font Awesome 6 Brands";
        padding: 0;
        margin: 0;
        font-size: 14px;
        min-height: 24px;
      }

      tooltip {
        border-radius: 5px;
        border: 1px solid white;
        background: #161616;
      }

      #waybar {
        color: @foreground;
        background-color: @background;
      }

      #workspaces {
        margin-right: 1rem;
        transition: none;
        background: #161616;
      }

      #workspaces button {
        transition: none;
        color: white;
        background: transparent;
        padding: 5px;
        margin-left: 0.2em;
      }

      #workspaces button.persistent {
        color: #7c818c;
      }

      #workspaces button.focused {
        color: red;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      #workspaces button:hover {
        transition: none;
        box-shadow: inherit;
        text-shadow: inherit;
        border-radius: inherit;
        color: #161616;
        background: #7c818c;
      }

      #workspaces button.focused {
        color: white;
      }

      #workspaces button.active {
        transition: none;
        box-shadow: inherit;
        text-shadow: inherit;
        border-radius: inherit;
        color: #7c818c;
        background: transparent;
      }

      #memory,
      #custom-platform-profile {
        padding-left: 1em;
      }

      #temperature.critical {
        color: #eb4d4b;
      }
      #privacy-item {
        color: red;
      }
      #privacy-item.screenshare {
        color: green;
      }
      #privacy-item.audio-in {
        color: orange;
      }
      #privacy-item.audio-out {
        color: orange;
      }

      #battery {
        color: white;
      }

      #battery.charging {
        color: green;
      }

      #battery.warning {
        color: orange;
      }

      #battery.critical {
        color: red;
      }

      #wireplumber,
      #battery,
      #idle_inhibitor,
      #network,
      #bluetooth,
      #tray,
      #backlight,
      #custom-notification {
        padding-right: 1em;
      }
    '';
  };
}
