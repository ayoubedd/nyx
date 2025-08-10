{ ... }: {

  imports = [
    ../../modules/hm

    ./pkgs.nix
    ./misc.nix
    ./flatpak.nix

    ./git.nix

    ../../misc/hm/desktops/hyprland
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "orbit";
  home.homeDirectory = "/home/orbit";

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}

