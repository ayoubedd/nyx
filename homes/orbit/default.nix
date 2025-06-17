{ inputs, ... }: {

  imports = [
    inputs.orbit-nvim.homeManagerModules.orbit-nvim
    inputs.nix-flatpak.homeManagerModules.nix-flatpak

    ./pkgs.nix
    ./misc.nix
    ./git.nix

    ./flatpak.nix

    ../../misc/hm/desktops/hyprland
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "orbit";
  home.homeDirectory = "/home/orbit";

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}

