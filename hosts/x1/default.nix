# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ lib, pkgs, nixos-hardware, config, inputs, ... }:
let
  misc = ../../misc/nixos;

  common = (builtins.toPath "${misc}/common");
  qemu = (builtins.toPath "${misc}/apps/qemu.nix");
  docker = (builtins.toPath "${misc}/apps/docker.nix");
  thunar = (builtins.toPath "${misc}/apps/thunar.nix");
  polkitAgent =
    (import (builtins.toPath "${misc}/apps/polkit_pantheon_agent.nix") {
      inherit pkgs;
      wantedBy = "hyprland-session.target";
    });
in {
  imports = [
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
    inputs.sops-nix.nixosModules.sops

    common
    qemu
    docker
    thunar
    polkitAgent

    ./hardware-configuration.nix
    ./misc.nix
    ./power.nix
    ./security.nix
    ./vpn.nix
    ./sops.nix
  ];

  nixpkgs.config.allowUnfree = true;

  services.devmon.enable = lib.mkForce false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "x1";
  networking.useDHCP = lib.mkDefault true;

  # Local
  time.timeZone = "Africa/Casablanca";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  programs.hyprland.enable = true;

  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root_password.path;
  };

  users.users.orbit = with pkgs; {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" ]
      ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd"
      ++ lib.optional config.virtualisation.docker.enable "docker"
      ++ lib.optional config.networking.networkmanager.enable "networkmanager";
    hashedPasswordFile = config.sops.secrets.user_password.path;
    shell = zsh;
  };

  system.stateVersion = "24.11";
}
