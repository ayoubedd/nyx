{ config, pkgs, lib, inputs, ... }: {

  imports = [
    inputs.nur.modules.homeManager.default
    inputs.stylix.homeManagerModules.stylix
    inputs.orbit-nvim.homeManagerModules.orbit-nvim

    ./pkgs.nix
    ./misc.nix
    ./git.nix

    ../../misc/hm/desktops/hyprland
    ../../misc/hm/browsers/firefox.nix
    ../../misc/hm/terminals/alacritty
    ../../misc/hm/shells/zsh
    ../../misc/hm/mux/zellij
    ../../misc/hm/media/mpv.nix
    ../../misc/hm/media/zathura.nix
  ];

  orbit-nvim.enable = true;
  orbit-nvim.neovide = true;

  nixpkgs.config.allowUnfree = true;

  home.username = "orbit";
  home.homeDirectory = "/home/orbit";

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}

