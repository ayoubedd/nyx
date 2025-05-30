# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:
let
  mixins = ../../mixins/nixos;

  common = (builtins.toPath "${mixins}/apps/common.nix");
  # qemu = (builtins.toPath "${mixins}/qemu.nix");
  docker = (builtins.toPath "${mixins}/apps/docker.nix");
  thunar = (builtins.toPath "${mixins}/apps/thunar.nix");

  disko = import ./disk-config.nix { device = "/dev/xxx"; };

  polkitAgent =
    (import (builtins.toPath "${mixins}/apps/polkit_pantheon_agent.nix") {
      inherit pkgs;
      wantedBy = "hyprland-session.target";
    });
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nvidia.nix
    ./services.nix
    # ./virtualisation.nix
    ./xdg.nix
    ./sysctl.nix

    inputs.disko.nixosModules.disko
    disko

    common
    # qemu
    docker
    thunar
    polkitAgent
  ];

  boot.kernelParams = [ "amd-pstate=active" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "kraken"; # Define your hostname.

  # Timezone
  time.timeZone = "Africa/Casablanca";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.bluetooth.powerOnBoot =
    lib.mkForce true; # Overriding common nixos config

  programs.hyprland.enable = true;
  security.polkit.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Users
  users.users.orbit = with pkgs; {
    initialPassword = "toor";
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" ]
      ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd"
      ++ lib.optional config.virtualisation.docker.enable "docker"
      ++ lib.optional config.networking.networkmanager.enable "networkmanager";
    shell = zsh;
  };

  system.stateVersion = "24.11"; # Did you read the comment?
}
