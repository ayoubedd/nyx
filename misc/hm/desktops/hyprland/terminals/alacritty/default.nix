{ pkgs, ... }:
{

  home.packages = with pkgs; [ alacritty ];

  home.file = {
    ".config/alacritty" = {
      source = ./config;
      recursive = true;
    };
  };
}
