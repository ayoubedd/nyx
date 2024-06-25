{ config, pkgs, ... }: {

  imports = [
    ./pkgs.nix
    ./files.nix
    ./fonts.nix

    ../../modules/desktops/sway

    ../../modules/editors/neovim
    ../../modules/terminals/alacritty
    ../../modules/shells/zsh
  ];

  home.sessionVariables = import ./vars.nix;

  home.username = "orbit";
  home.homeDirectory = "/home/orbit";

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
