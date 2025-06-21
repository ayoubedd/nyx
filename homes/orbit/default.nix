{ inputs, ... }: {

  imports = [
    # inputs.orbit-nvim.homeManagerModules.orbit-nvim
    inputs.nix-flatpak.homeManagerModules.nix-flatpak

    ../../modules/hm

    ./pkgs.nix
    ./misc.nix
    ./flatpak.nix

    ./git.nix

    ../../misc/hm/desktops/hyprland
    ../../misc/hm/editors/nvim
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "orbit";
  home.homeDirectory = "/home/orbit";

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}

