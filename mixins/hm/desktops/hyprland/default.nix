{ pkgs, my-pkgs, host, ... }:
{

  imports = [
    # import home manager custom modules
    ../../../../modules/hm

    # Hyprland config
    ./hyprland.nix

    # Fonts and GTK theming
    ./fonts.nix
    ./theming.nix

    # XDG stuff
    ./xdg.nix

    # Applets
    ./applets

    ./device/${host}
  ];

  home.packages = with pkgs;
    [
      my-pkgs.realod-failed-services
      wl-clipboard
      wl-color-picker
      slurp
      grim
      # wtype
      wofi-emoji
      jq
      wl-clip-persist # should write a module for this
    ];
}
