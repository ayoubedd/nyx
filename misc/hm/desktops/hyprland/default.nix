{ pkgs, lo-pkgs, host, ... }: {

  imports = [
    # import home manager custom modules
    ../../../../modules/hm

    ../../common

    # Hyprland config
    ./hyprland.nix

    # Fonts and GTK theming
    ./fonts.nix
    ./theming.nix

    # XDG stuff
    ./xdg.nix

    # Applets
    ./applets

    ../../browsers/firefox.nix
    ../../terminals/alacritty
    ../../shells/zsh
    ../../media/mpv.nix
    ../../media/imv.nix
    ../../media/zathura.nix

    ./device/${host}
  ];

  home.packages = with pkgs; [
    lo-pkgs.realod-failed-services
    wl-clipboard
    wl-color-picker
    slurp
    grim
    wofi-emoji
    jq
    wl-clip-persist # should write a module for this
  ];
}
