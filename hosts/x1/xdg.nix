{ pkgs, lib, ... }: {
  xdg.terminal-exec.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr xdg-desktop-portal-hyprland ];

    config = {
      common = {
        default = [
          "gtk"
        ];
      };
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
      sway = {
        default = lib.mkDefault [
          "wlr"
          "gtk"
        ];
      };
    };
  };
}
