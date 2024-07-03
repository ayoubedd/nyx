{ config, pkgs, ... }: {

  imports = [
    ./pkgs.nix
    ./files.nix
    ./fonts.nix
    ./services.nix

    ../../modules/hm/desktops/sway

    ../../modules/hm/browsers/firefox.nix
    ../../modules/hm/editors/neovim
    ../../modules/hm/terminals/alacritty
    ../../modules/hm/shells/zsh
    ../../modules/hm/media/mpv
    ../../modules/hm/mux/zellij

    ./git.nix
  ];

  home.sessionVariables = import ./vars.nix;

  home.username = "orbit";
  home.homeDirectory = "/home/orbit";

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}


