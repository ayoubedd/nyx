{ pkgs, ... }:
{

  imports = [
    # Hyprland config
    ./hyprland.nix

    
    # Fonts and GTK theming
    ./fonts.nix
    ./theming.nix

    # XDG stuff
    ./xdg.nix

    # Applets
    ./applets/waybar.nix
    ./applets/mako.nix
    ./applets/wofi.nix
    ./applets/kanshi.nix
  ];

  home.packages = with pkgs; [
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
