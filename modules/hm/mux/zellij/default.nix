{ ... }: {
  programs.zellij.enable = true;

  xdg.configFile."zellij" = {
    enable = true;
    recursive = true;
    source = ./config;
  };
}
