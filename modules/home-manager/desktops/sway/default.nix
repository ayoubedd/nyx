{ pkgs, ... }: {

  imports = [
    ./fonts.nix
    ./services.nix
    ./scripts.nix
    ./config.nix

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
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
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

  services.gnome-keyring = {
    enable = true;
  };

  services.poweralertd.enable = true;
}
