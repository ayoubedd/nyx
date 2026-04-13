{ pkgs, lib, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  #
  environment.systemPackages = with pkgs; [
    firefox
    nginx
    docker
  ];

  nixpkgs.config.pulseaudio = true;

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };

  services.displayManager.defaultSession = "xfce";

  system.stateVersion = "26.05";
}
