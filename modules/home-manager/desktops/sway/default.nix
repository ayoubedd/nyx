{ pkgs, ... }: {

  imports = [
    ./fonts.nix
    ./services.nix
    ./scripts.nix

    ../applets/wofi
    ../applets/waybar
    ../applets/swaylock
    ../applets/mako
    ../applets/kanshi
    ../applets/swayimg
  ];

  home.packages = with pkgs; [
    wl-clipboard
    swaybg
    brightnessctl
    wl-color-picker
    slurp
    grim
    wtype
    wofi-emoji
    jq
  ];

  programs.dconf.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    wrapperFeatures = {
      gtk = true;
      base = true;
    };
  };

  xdg.configFile."sway" = {
    enable = true;
    source = ./config;
    recursive = true;
  };

  gtk = {
    enable = true;

    cursorTheme = {
      size = 24;
      name = "volantes_cursors";
      package = pkgs.volantes-cursors;
    };

    iconTheme = {
      package = (pkgs.colloid-icon-theme.override { schemeVariants = [ "nord" ]; });
      name = "Colloid-nord-dark";
    };

    theme = {
      package = (pkgs.colloid-gtk-theme.override { tweaks = [ "nord" ]; colorVariants = [ "dark" ]; });
      name = "Colloid-Dark-Nord";
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  home.preferXdgDirectories = true;

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr ];
    xdgOpenUsePortal = true;
    config = {
      common = {
        default = [
          "gtk"
        ];
      };
      # pantheon = {
      #   default = [
      #     "pantheon"
      #     "gtk"
      #   ];
      #   "org.freedesktop.impl.portal.Secret" = [
      #     "gnome-keyring"
      #   ];
      # };
      # x-cinnamon = {
      #   default = [
      #     "xapp"
      #     "gtk"
      #   ];
      # };
    };
  };

  services.poweralertd.enable = true;
}
