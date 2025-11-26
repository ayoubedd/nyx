{
  lib,
  pkgs,
  nixos-hardware,
  config,
  inputs,
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
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko

    ../../misc/nixos/common
    ../../misc/nixos/apps/qemu.nix
    ../../misc/nixos/apps/docker.nix
    ../../misc/nixos/apps/thunar.nix
    polkitAgent

    ./hardware-configuration.nix
    ./misc.nix
    ./power.nix
    ./security.nix
    # ./vpn.nix
    ./sops.nix
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
    hashedPasswordFile = config.sops.secrets.user_password.path;
    shell = zsh;
  };

  system.stateVersion = "24.11";
}
