{ pkgs, ... }: {
  home.packages = with pkgs; [ waybar ];

  home.file.".config/waybar" = {
    source = ./config;
    recursive = true;
  };
}
