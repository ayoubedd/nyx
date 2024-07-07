{ pkgs, ... }:
{

  imports = [
    ./hyprland.nix

    ../common/applets/wofi
    ./applets/kanshi.nix

    ./fonts.nix

    ../common/theming/cursor_volantes.nix
    ../common/theming/gtk_colloid.nix

    ../common/dconf/common.nix

    ../common/xdg/common.nix

    ./mime_apps.nix

    ./applets/waybar.nix
    ./applets/mako.nix
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
