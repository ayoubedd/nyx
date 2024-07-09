# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ lib, pkgs, nixos-hardware, ... }:


{
  imports = [
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
    ./hardware-configuration.nix
    ./modprobe.nix
    ./services.nix
    ./udev.nix
    ./power.nix
    ../../mixins/nixos/common.nix
    (import ../../mixins/nixos/polkit_pantheon_agent.nix { inherit pkgs; wantedBy = "hyprland-session.target"; })
    ./xdg.nix
  ];

  nixpkgs.config.allowUnfree = true;

  services.devmon.enable = lib.mkForce false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.binfmt.emulatedSystems = [
    "wasm32-wasi"
    "aarch64-linux"
    "riscv64-linux"
    "riscv32-linux"
  ];
  boot.consoleLogLevel = 4;

  networking.hostName = "x1";

  # Set your time zone.
  time.timeZone = "Africa/Casablanca";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  programs.sway.enable = true;
  programs.hyprland.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock = { };

  programs.zsh.enable = true;

  # Users
  users.users.orbit = with pkgs; {
    initialPassword = "toor";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "docker" "audio" ];
    shell = zsh;
  };

  # Docker
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    neovim
    curl
    qemu
    qt5.qtwayland
  ];

  # Thunar
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
    thunar-media-tags-plugin
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  programs.xfconf.enable = true;
  services.tumbler.enable = true;

  system.stateVersion = "24.11";
}

