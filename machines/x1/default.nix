{
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    ../../misc/nixos/common
    # ../../misc/nixos/apps/qemu.nix
    ../../misc/nixos/apps/docker.nix
    ../../misc/nixos/apps/thunar.nix
    ../../misc/nixos/apps/polkit_gnome_agent.nix

    ./hardware.nix
    ./misc.nix
    ./power.nix
    ./security.nix
    ./sops.nix
    ./disk.nix
    ./net

    ./users/root
    ./users/orbit
  ];

  networking.hostName = "x1";
  networking.useDHCP = lib.mkDefault true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = false;
  home-manager.extraSpecialArgs = {
    inherit inputs;
    host = config.networking.hostName;
    stateVersion = config.system.stateVersion;
  };

  system.stateVersion = "26.05";
}
