{ lib, pkgs, ... }: {
  # depedent packges
  home.packages = with pkgs; [ font-awesome noto-fonts ];

  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        "modules-left" = [ "hyprland/workspaces" ];
        "modules-center" = [ "clock" ];
        "modules-right" = [
          "network"
          "pulseaudio"
          "cpu"
          "memory"
          "temperature"
          "upower"
          "backlight"
          "tray"
          "custom/notification"
        ];

        "network" = {
          "interface" = "wlp0s20f3";
          "format" = "{ifname} {bandwidthDownBytes}";
          "format-wifi" = "{essid}  ";
          "format-ethernet" = "{ipaddr}/{cidr} 󰊗";
          "format-disconnected" = ""; # An empty format will hide the module.
          "tooltip-format" = "{ifname} via {gwaddr} 󰊗";
          "tooltip-format-wifi" = "Signal Strength ({signalStrength}%)  ";
          "tooltip-format-ethernet" = "{ifname} ";
          "tooltip-format-disconnected" = "Disconnected";
          "max-length" = 60;
        };

        "hyprland/workspaces" = {
          "disable-scroll" = true;
          "format" = "{icon}";
          "persistent_workspaces" = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
            "6" = [ ];
          };
        };

        "clock" = {
          "tooltip-format" = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
          "format" = "{:%a, %d %b, %H:%M}";
        };

        "pulseaudio" = {
          "reverse-scrolling" = 1;
          "format" = "{volume}% {icon} {format_source}";
          "format-bluetooth" = "{volume}% {icon}   {format_source}";
          "format-bluetooth-muted" = "{icon}  {format_source}";
          "format-muted" = "{format_source}";
          "format-source" = "{volume}% ";
          "format-source-muted" = "";
          "format-icons" = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [ "Speaker" ];
          };
          "on-click" = "pavucontrol";
          "min-length" = 13;
        };

        "custom/notification" = {
          "tooltip" = false;
          "format" = "{icon}";
          "format-icons" = {
            "notification" = "<span foreground='red'><sup></sup></span>";
            "none" = "";
            "dnd-notification" = "<span foreground='red'><sup></sup></span>";
            "dnd-none" = "";
            "inhibited-notification" =
              "<span foreground='red'><sup></sup></span>";
            "inhibited-none" = "";
            "dnd-inhibited-notification" =
              "<span foreground='red'><sup></sup></span>";
            "dnd-inhibited-none" = "";
          };
          "return-type" = "json";
          "exec-if" = "which swaync-client";
          "exec" = "swaync-client -swb";
          "on-click" = "swaync-client -t -sw";
          "on-click-right" = "swaync-client -d -sw";
          "escape" = true;
        };
        "temperature" = {
          "critical-threshold" = 80;
          "format" = "{temperatureC}°C {icon}";
          "format-icons" = [ "" "" "" "" "" ];
          "tooltip" = false;
          "hwmon-path" = [ "/sys/class/hwmon/hwmon5/temp1_input" ];
        };

        "backlight" = {
          "device" = "intel_backlight";
          "format" = "{percent}% {icon}";
          "format-icons" = [ "" "" "" "" ];
          "min-length" = 7;
        };

        "cpu" = {
          "interval" = 10;
          "format" = "{}%  ";
          "max-length" = 10;
        };

        "memory" = {
          "interval" = 30;
          "format" = "{}% ";
          "max-length" = 10;
        };

        "tray" = {
          "icon-size" = 16;
          "spacing" = 10;
        };
      };
    };

    style = ''
      * {
          border: none;
          border-radius: 0;
          /* `otf-font-awesome` is required to be installed for icons */
          font-family: Noto Sans;
          font-size: 14px;
          min-height: 24px;
      }
        #custom-notification {
          margin-right: 8px;
          font-family: "Noto Sans";
        }

      window#waybar {
          background: #161616;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      #workspaces {
          margin-right: 8px;
          transition: none;
          background: #161616;
      }

      #workspaces button {
          transition: none;
          color: #7c818c;
          background: transparent;
          padding: 5px;
      }

      #workspaces button.persistent {
          color: #7c818c;
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
          color: #161616;
          background: #7c818c;
      }

      #mode {
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #clock {
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #pulseaudio {
          margin-right: 8px;
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #pulseaudio.muted {
          background-color: #90b1b1;
          color: #2a5c45;
      }

      #memory {
          padding-left: 5px;
          padding-right: 5px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #backlight {
          margin-right: 8px;
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #battery {
          margin-right: 8px;
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #battery.charging {
          color: #ffffff;
          background-color: #26A65B;
      }

      #battery.warning:not(.charging) {
          background-color: #ffbe61;
          color: black;
      }

      #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: #ffffff;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }



      #cpu {
          /* margin-right: 8px; */
          padding-left: 16px;
          padding-right: 5px;
          border-radius: 10px 0 0 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #network {
          margin-right: 8px;
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #temperature {
          padding-left: 5px;
          padding-right: 5px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #temperature.critical {
          background-color: #eb4d4b;
      }

      #upower {
          margin-right: 8px;
          padding-left: 5px;
          padding-right: 16px;
          border-radius:  0 10px 10px 0;
          transition: none;
          color: #ffffff;
          background: #161616;
      }



      #tray {
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      @keyframes blink {
          to {
              background-color: #ffffff;
              color: #000000;
          }
      }
    '';
  };
}
