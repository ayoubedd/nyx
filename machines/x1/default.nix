{
  lib,
  pkgs,
  config,
  ...
}:
let
  misc = ../../misc/nixos;
  polkitAgent = (
    import (builtins.toPath "${misc}/apps/polkit_pantheon_agent.nix") {
      inherit pkgs;
      wantedBy = "hyprland-session.target";
    }
  );
in
{
  imports = [
    ../../misc/nixos/common
    # ../../misc/nixos/apps/qemu.nix
    ../../misc/nixos/apps/docker.nix
    ../../misc/nixos/apps/thunar.nix
    polkitAgent

    ./hardware-configuration.nix
    ./misc.nix
    ./power.nix
    ./security.nix
    ./vpn.nix
    ./sops.nix
    ./disko.nix
  ];
  boot.kernelParams = [
    "nowatchdog"
    "kernel.nmi_watchdog=0"
  ];

  networking.hostName = "x1";
  networking.useDHCP = lib.mkDefault true;

  services.devmon.enable = lib.mkForce false;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Users
  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root_password.path;
  };

  users.users.orbit = with pkgs; {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
    ]
    ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd"
    ++ lib.optional config.virtualisation.docker.enable "docker"
    ++ lib.optional config.networking.networkmanager.enable "networkmanager";
    hashedPasswordFile = config.sops.secrets.orbit_password.path;
    shell = zsh;
  };

  system.stateVersion = "26.05";
}
