{ pkgs, ... }:
{
  services.vicinae = {
    enable = true;
    package = pkgs.vicinae;
    systemd = {
      enable = true;
      autoStart = true;
    };
    settings = {
      faviconService = "twenty";
      font.size = 11;
      popToRootOnClose = true;
      rootSearch.searchFiles = false;
      window = {
        csd = true;
        rounding = 7;
      };
    };
  };
}
