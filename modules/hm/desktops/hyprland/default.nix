{ pkgs, ... }:
let
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  pidof = "${pkgs.procps}/bin/pidof";

  homescreen_img = ../../../../media/images/homescreen.png;
  lockscreen_img = ../../../../media/images/lockscreen.png;
in
{

  imports = [
    ../applets/waybar
    ./kanshi.nix


    ../theming/cursor_volantes.nix
    ../theming/gtk_colloid.nix
    ./hyprland.nix

    ../xdg/common.nix
    ../dconf/common.nix
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
