{ pkgs, ... }: {

  imports = [
    ./services.nix
    ./scripts.nix
    ./sway.nix

    ./applets/wofi
    ./applets/waybar
    ./applets/swaylock
    ./applets/mako
    ./applets/swayimg
    ./applets/kanshi.nix

    ./theming.nix
    ./fonts.nix

    ./xdg.nix
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

