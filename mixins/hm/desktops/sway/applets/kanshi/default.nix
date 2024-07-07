{ pkgs, ... }: {
  # home.packages = with pkgs; [ kanshi ];

  home.file.".config/kanshi" = {
    source = ./config;
    recursive = true;
  };

  services.kanshi.enable = true;
  services.kanshi.systemdTarget = "sway-session.target";
}
