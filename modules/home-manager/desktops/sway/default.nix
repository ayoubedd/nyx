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
}
