{ inputs, config, ... }:
{

  imports = [
    ../../modules/hm

    ./pkgs.nix
    ./misc.nix
    ./flatpak.nix

    ./git.nix

    ../../misc/hm/desktops/hyprland
  ];

  nixpkgs.config.allowUnfree = true;

  news.display = "silent";

  home.username = "orbit";
  home.homeDirectory = "/home/orbit";

  programs.home-manager.enable = true;

  home.file."${config.home.homeDirectory}/Pictures/Wallpapers" = {
    source = ../../assets/images/wallpapers;
    recursive = true;
  };

  home.stateVersion = "26.05";
}
