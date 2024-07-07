{ pkgs, ... }: {

  imports = [
    ./fonts.nix
    ./services.nix
    ./scripts.nix
    ./sway.nix

    ../common/applets/wofi
    ../common/applets/waybar
    ../common/applets/swaylock
    ../common/applets/mako
    ../common/applets/swayimg

    ./kanshi.nix


    ../common/theming/gtk_colloid.nix
    ../common/theming/cursor_volantes.nix

    ../common/xdg/common.nix
    ../common/dconf/common.nix
    ./mime_apps.nix
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
}

