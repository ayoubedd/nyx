{ pkgs, ... }: {
  home.packages = with pkgs; [ swayimg ];

  home.file.".config/swayimg" = {
    source = ./config;
    recursive = true;
  };
}
