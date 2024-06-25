{ pkgs, ... }: {
  home.packages = with pkgs; [ swaylock-effects swayidle ];

  home.file.".config/swaylock" = {
    source = ./config;
    recursive = true;
  };
}
