{ pkgs, lib, ... }: {
  home.pointerCursor = {
    # size = 24;
    # name = "volantes_cursors";
    # package = pkgs.volantes-cursors;
    x11 = {
      enable = true;
      defaultCursor = "volantes_cursors";
    };
  };

  gtk = {
    enable = true;
    cursorTheme = {
      size = 24;
      name = "volantes_cursors";
      package = pkgs.volantes-cursors;
    };

    iconTheme = {
      package =
        (pkgs.colloid-icon-theme.override { colorVariants = [ "grey" ]; });
      name = "Colloid-Grey-Dark";
    };

    # theme = {
    #   package = (pkgs.colloid-gtk-theme.override { tweaks = [ "nord" ]; colorVariants = [ "dark" ]; });
    #   name = "Colloid-Dark-Nord";
    # };

    gtk3.extraConfig = { gtk-application-prefer-dark-theme = true; };

    gtk4.extraConfig = { gtk-application-prefer-dark-theme = true; };
  };

  stylix = {
    enable = true;
    image = ../../../../assets/images/homescreen.png;

    targets.hyprpaper.enable = lib.mkForce false;
    targets.wofi.enable = false;
    targets.neovim.enable = false;
    targets.hyprlock.enable = false;
    targets.hyprland.enable = false;

    cursor.name = "volantes_cursors";
    cursor.size = 24;
    cursor.package = pkgs.volantes-cursors;

    fonts.monospace = {
      name = "Noto Sans Mono";
      package = pkgs.noto-fonts;
    };

    fonts.sansSerif = {
      name = "Noto Sans";
      package = pkgs.noto-fonts;
    };

    fonts.serif = {
      name = "Noto Sans";
      package = pkgs.noto-fonts;
    };

    fonts.sizes.applications = 11;

    polarity = "dark";

    base16Scheme = {
      base00 = "161616";
      base01 = "252525";
      base02 = "353535";
      base03 = "484848";
      base04 = "7b7c7e";
      base05 = "f2f4f8";
      base06 = "b6b8bb";
      base07 = "e4e4e5";
      base08 = "ee5396";
      base09 = "3ddbd9";
      base0A = "08bdba";
      base0B = "25be6a";
      base0C = "33b1ff";
      base0D = "78a9ff";
      base0E = "be95ff";
      base0F = "ff7eb6";
    };

    targets.firefox.profileNames = [ "orbit" ];
  };
}
