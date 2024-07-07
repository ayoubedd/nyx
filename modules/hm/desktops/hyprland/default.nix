{ pkgs, ... }:
{

  imports = [
    ./hyprland.nix

    ../applets/waybar
    ../applets/wofi
    ./kanshi.nix

    ./fonts.nix

    ../theming/cursor_volantes.nix
    ../theming/gtk_colloid.nix

    ../dconf/common.nix

    ../xdg/common.nix

    ./mime_apps.nix

    ./applets/waybar.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard
    wl-color-picker
    slurp
    grim
    # wtype
    wofi-emoji
    jq
    pkgs.wl-clip-persist # should write a module for this
  ];
}
