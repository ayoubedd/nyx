{ inputs, ... }: {


  programs.sherlock = {
    enable = true;

    settings = {
      config = {
        default_apps = { terminal = "alacritty"; };

        appearance = {
          width = 700;
          height = 460;
          gsk_renderer = "cairo";
          recolor_icons = false;
          icon_size = 25;
          search_icon = false;
          use_base_css = true;
          status_bar = false;
        };

        behavior = {
          caching = true;
          cache = "~/.cache/sherlock_desktop_cache.json";
          daemonize = false;
          animation = false;
        };

        binds = {
          prev = "control-p";
          next = "control-n";
        };
      };
    };
  };
}
