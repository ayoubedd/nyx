{ pkgs, ... }: {

  imports = [
    ./fonts.nix
    ./services.nix
    ./scripts.nix
    ./sway.nix

    ../applets/wofi
    ../applets/waybar
    ../applets/swaylock
    ../applets/mako
    ../applets/swayimg

    ./kanshi.nix


    ../theming/gtk_colloid.nix
    ../theming/cursor_volantes.nix

    ../xdg/common.nix
    ../dconf/common.nix
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


  services.gnome-keyring = {
    enable = true;
  };

  services.poweralertd.enable = true;
}

