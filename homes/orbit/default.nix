{ config, pkgs, lib, ... }: {

  imports = [
    ./pkgs.nix
    ./files.nix
    ./fonts.nix
    ./services.nix

    # ../../mixins/hm/desktops/sway
    ../../mixins/hm/desktops/hyprland

    ../../mixins/hm/browsers/firefox.nix
    ../../mixins/hm/browsers/chromium.nix

    ../../mixins/hm/terminals/alacritty
    ../../mixins/hm/shells/zsh
    ../../mixins/hm/mux/zellij
    ../../mixins/hm/editors/neovim
    ../../mixins/hm/media/mpv.nix

    ./git.nix
  ];

  home.sessionVariables = import ./vars.nix;

  home.username = "orbit";
  home.homeDirectory = "/home/orbit";

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}


