{ pkgs, ... }: {
  home.packages = with pkgs; [ swaylock-effects swayidle roboto ];

  home.file.".config/swaylock" = {
    source = ./config;
    recursive = true;
  };

}
