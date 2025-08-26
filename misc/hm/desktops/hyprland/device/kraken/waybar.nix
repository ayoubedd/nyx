{ lib, ... }:
{
  programs.waybar = {
    settings = {
      mainBar = {
        "modules-right" = lib.mkForce [
          "network"
          "pulseaudio"
          "cpu"
          "memory"
          "tray"
        ];
      };
    };
  };
}
