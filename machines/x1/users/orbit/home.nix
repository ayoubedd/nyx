{
  config,
  stateVersion,
  inputs,
  ...
}:
{

  imports = with inputs; [
    vicinae.homeManagerModules.default
    stylix.homeModules.stylix
    nur.modules.homeManager.default
    nix-flatpak.homeManagerModules.nix-flatpak

    ../../../../modules/hm

    ./pkgs.nix
    ./misc.nix
    ./flatpak.nix

    ./git.nix
    ./ai

    ../../../../misc/hm/desktops/hyprland
    ../../../../misc/hm/desktops/hyprland/browsers/firefox.nix
  ];

  news.display = "silent";

  home.username = "orbit";
  home.homeDirectory = "/home/orbit";

  programs.home-manager.enable = true;

  home.file."${config.home.homeDirectory}/Pictures/Wallpapers" = {
    source = ../../../../assets/images/wallpapers;
    recursive = true;
  };

  home.stateVersion = stateVersion;
}
