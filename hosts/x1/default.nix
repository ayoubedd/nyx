# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ lib, pkgs, nixos-hardware, config, ... }:
let
  mixins = ../../mixins/nixos;

  common = (builtins.toPath "${mixins}/common.nix");
  qemu = (builtins.toPath "${mixins}/qemu.nix");
  docker = (builtins.toPath "${mixins}/docker.nix");
  thunar = (builtins.toPath "${mixins}/thunar.nix");

  polkitAgent = (import (builtins.toPath "${mixins}/polkit_pantheon_agent.nix") { inherit pkgs; wantedBy = "hyprland-session.target"; });
in
{
  imports = [
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
    ./hardware-configuration.nix
    ./services.nix
    ./udev.nix
    ./power.nix
    ./xdg.nix

    common
    qemu
    docker
    thunar
    polkitAgent
  ];

  services.logind.lidSwitch = "ignore";

  nixpkgs.config.allowUnfree = true;

  services.devmon.enable = lib.mkForce false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "x1";

  # Set your time zone.
  time.timeZone = "Africa/Casablanca";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  programs.sway.enable = true;
  programs.hyprland.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock = { };

  # Users
  users.users.orbit = with pkgs; {
    initialPassword = "toor";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
    ]
    ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd"
    ++ lib.optional config.virtualisation.docker.enable "docker"
    ++ lib.optional config.networking.networkmanager.enable "networkmanager";
    shell = zsh;
  };

  system.stateVersion = "24.11";
}

