{ pkgs, ... }: {
  home.packages = with pkgs; [ kanshi ];

  home.file.".config/kanshi" = {
    source = ./config;
    recursive = true;
  };
}
