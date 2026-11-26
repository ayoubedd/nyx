{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.pointerCursor = {
    enable = true;
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
      package = (pkgs.colloid-icon-theme.override { colorVariants = [ "grey" ]; });
      name = "Colloid-Grey-Dark";
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # The stylix palette and fonts for quickshell (common/Theme.qml reads this,
  # live: a rebuild recolours the bar without a restart; the greeter gets the
  # same file from the store). Hex with "#".
  xdg.configFile."nyx/theme.json".text = builtins.toJSON (
    lib.genAttrs (map (n: "base0${n}") [
      "0"
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
      "8"
      "9"
      "A"
      "B"
      "C"
      "D"
      "E"
      "F"
    ]) (name: config.lib.stylix.colors.withHashtag.${name})
    // {
      fontSans = config.stylix.fonts.sansSerif.name;
      fontMono = config.stylix.fonts.monospace.name;
    }
  );

  stylix = {
    enable = true;
    polarity = "dark";

    # rofi isn't used; stylix's rofi module still sets the renamed
    # programs.rofi.font (eval warning).
    targets.rofi.enable = false;
    targets.neovim.enable = false;
    targets.hyprlock.enable = false;
    targets.hyprland.enable = false;
    # Off: kitty keeps its own font (JetBrainsMono NF) and colour mapping;
    # the colours still come from this scheme (terminals/kitty/default.nix).
    targets.kitty.enable = lib.mkForce false;

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

    targets.librewolf.profileNames = [ config.home.username ];
    targets.librewolf.colorTheme.enable = true;

    targets.qt = {
      standardDialogs = "xdgdesktopportal";
    };
  };
}
