{ ... }:
{

  programs.sherlock = {
    enable = true;

    settings = {
      default_apps = {
        terminal = "alacritty";
        browser = "firefox %U";
      };

      units = {
        lengths = "meters";
        weights = "kg";
        volumes = "l";
        temperatures = "C";
        currency = "dollar";
      };

      appearance = {
        width = 700;
        height = 460;
        gsk_renderer = "vulkan";
        recolor_icons = false;
        icon_size = 22;
        search_icon = true;
        use_base_css = true;
        status_bar = true;
        search_icon_size = 22;
      };

      behavior = {
        caching = true;
        cache = "~/.cache/sherlock_desktop_cache.json";
        daemonize = true;
        animation = true;
      };

      binds = {
        up = "control-p";
        down = "control-n";
      };

      launchers = [
        {
          name = "Weather";
          type = "weather";
          args = {
            location = "Marrakech";
            update_interval = 60;
          };
          priority = 1;
          home = true;
          only_home = true;
          async = true;
          shortcut = false;
          spawn_focus = false;
        }
        {
          name = "Clipboard";
          type = "clipboard-execution";
          args = { };
          priority = 1;
          home = true;
        }
        {
          name = "Spotify";
          type = "audio_sink";
          args = { };
          async = true;
          priority = 1;
          home = true;
          spawn_focus = false;
        }
        {
          name = "Calculator";
          type = "calculation";
          args = { };
          priority = 1;
        }
        {
          name = "App Launcher";
          alias = "app";
          type = "app_launcher";
          args = { };
          priority = 2;
          home = true;
        }
        {
          name = "Wireguard";
          alias = "wg";
          type = "command";
          args = {
            commands = {
              "Homelab Connect" = {
                icon = "network-vpn";
                exec = "systemctl start wireguard-homelab.service &";
                search_string = "vpn;homelab";
              };
              "Homelab Disconnect" = {
                icon = "network-vpn";
                exec = "systemctl stop wireguard-homelab.service &";
                search_string = "vpn;homelab";
              };
            };
          };
          priority = 4;
        }
        {
          name = "Power Management";
          alias = "pm";
          type = "command";
          args = {
            commands = {
              Shutdown = {
                icon = "system-shutdown";
                exec = "systemctl poweroff";
                search_string = "Poweroff;Shutdown";
              };
              Sleep = {
                icon = "system-suspend";
                exec = "systemctl suspend";
                search_string = "Sleep;";
              };
              Lock = {
                icon = "system-lock-screen";
                exec = "systemctl suspend & swaylock";
                search_string = "Lock Screen;";
              };
              Reboot = {
                icon = "system-reboot";
                exec = "systemctl reboot";
                search_string = "reboot";
              };
            };
          };
          priority = 4;
        }
        {
          name = "Utilities";
          alias = "";
          type = "command";
          args = {
            commands = {
              "Color Picker" = {
                icon = "colorgrab";
                exec = "sleep 1; hyprpicker -a &";
                search_string = "colorpicker";
              };
            };
          };
          priority = 5;
        }
        {
          name = "Web Search";
          display_name = "Google Search";
          tag_start = "{keyword}";
          alias = "gg";
          type = "web_launcher";
          args = {
            search_engine = "google";
            icon = "google";
          };
          priority = 100;
        }
        {
          name = "YouTube Search";
          display_name = "Youtube Search";
          tag_start = "{keyword}";
          alias = "yt";
          type = "web_launcher";
          args = {
            search_engine = "https://www.youtube.com/results?search_query={keyword}";
            icon = "youtube";
          };
          priority = 0;
        }
      ];
    };
  };
}
