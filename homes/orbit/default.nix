{ config, pkgs, ... }: {

  imports = [
    ./pkgs.nix
    ./files.nix
    ./fonts.nix
    ./services.nix

    ../../modules/hm/desktops/sway

    ../../modules/hm/browsers/firefox.nix
    ../../modules/hm/browsers/chromium.nix

    ../../modules/hm/terminals/alacritty
    ../../modules/hm/shells/zsh
    ../../modules/hm/mux/zellij
    ../../modules/hm/editors/neovim
    ../../modules/hm/media/mpv

    ./git.nix
  ];

  home.sessionVariables = import ./vars.nix;

  home.username = "orbit";
  home.homeDirectory = "/home/orbit";

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}


