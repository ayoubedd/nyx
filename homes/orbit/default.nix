{ config, pkgs, lib, inputs, ... }: {

  imports = [
    inputs.nur.modules.homeManager.default
    inputs.stylix.homeManagerModules.stylix
    inputs.orbit-nvim.homeManagerModules.orbit-nvim

    ./pkgs.nix
    ./misc.nix
    ./git.nix

    ../../mixins/hm/desktops/hyprland
    ../../mixins/hm/browsers/firefox.nix
    ../../mixins/hm/terminals/alacritty
    ../../mixins/hm/shells/zsh
    ../../mixins/hm/mux/zellij
    ../../mixins/hm/media/mpv.nix
    ../../mixins/hm/media/zathura.nix
  ];

  orbit-nvim.enable = true;
  orbit-nvim.neovide = true;

  nixpkgs.config.allowUnfree = true;

  home.username = "orbit";
  home.homeDirectory = "/home/orbit";

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}

