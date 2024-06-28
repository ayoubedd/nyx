{ config, pkgs, ... }: {

  imports = [
    ./pkgs.nix
    ./files.nix
    ./fonts.nix
    ./services.nix

    ../../modules/home-manager/desktops/sway

    ../../modules/home-manager/editors/neovim
    ../../modules/home-manager/terminals/alacritty
    ../../modules/home-manager/shells/zsh
  ];

  home.sessionVariables = import ./vars.nix;

  home.username = "orbit";
  home.homeDirectory = "/home/orbit";

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
