# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:
let
  mixins = ../../mixins/nixos;

  common = (builtins.toPath "${mixins}/common.nix");
  qemu = (builtins.toPath "${mixins}/qemu.nix");
  docker = (builtins.toPath "${mixins}/docker.nix");
  thunar = (builtins.toPath "${mixins}/thunar.nix");

  disko = import ./disko.nix { device = "/dev/xxx"; };

  polkitAgent = (import (builtins.toPath "${mixins}/polkit_pantheon_agent.nix") { inherit pkgs; wantedBy = "hyprland-session.target"; });
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvidia.nix
      ./services.nix
      ./xdg.nix

      inputs.disko.nixosModules.disko
      disko

      common
      qemu
      docker
      thunar
      polkitAgent
    ];

  boot.kernelParams = [
    # "amd-pstate=active"
  ];

  programs.steam = {
    enable = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  # Hostname
  networking.hostName = "kraken"; # Define your hostname.
  networking.firewall.allowedTCPPorts = [ 1337 ]; # for quick file sharing

  # Timezone
  time.timeZone = "Africa/Casablanca";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.bluetooth.powerOnBoot = lib.mkForce true; # Overriding common nixos config

  boot.binfmt.emulatedSystems = [
    "wasm32-wasi"
    "aarch64-linux"
    "riscv64-linux"
    "riscv32-linux"
  ];
  boot.consoleLogLevel = 3;

  programs.hyprland.enable = true;
  security.polkit.enable = true;

  nixpkgs.config.allowUnfree = true;

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

  # System packages
  environment.systemPackages = with pkgs; [
    neovim
    curl
    qt5.qtwayland
  ];

  system.stateVersion = "24.11"; # Did you read the comment?
}

