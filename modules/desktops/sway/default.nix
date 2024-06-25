{ pkgs, ... }: {

  imports = [
    ./fonts.nix
    ./services.nix

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
  ];

  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
  };

  home.file.".config/sway" = {
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
      name = "elementary-Xfce-dark";
      package = pkgs.elementary-xfce-icon-theme;
    };

    theme = {
      name = "zukitre-dark";
      package = pkgs.zuki-themes;
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
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
}
