# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, hostname ? "nixos", nixos-hardware, ... }:


{
  imports = [
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
    ./hardware-configuration.nix
    ./modprobe.nix
    ./services.nix
    ./udev.nix
    ./power.nix
    ../../modules/nixos/common.nix
    (import ../../modules/nixos/polkit_pantheon_agent.nix { inherit pkgs; wantedBy = "hyprland-session.target"; })
  ];

  nixpkgs.config.allowUnfree = true;

  services.devmon.enable = lib.mkForce false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.binfmt.emulatedSystems = [
    "wasm32-wasi"
    "aarch64-linux"
    "riscv64-linux"
    "riscv32-linux"
  ];

  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
    thunar-media-tags-plugin
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  programs.xfconf.enable = true;
  services.tumbler.enable = true;

  boot.consoleLogLevel = 4;

  networking.hostName = hostname;

  # Set your time zone.
  time.timeZone = "Africa/Casablanca";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  xdg.terminal-exec.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr xdg-desktop-portal-hyprland ];

    config = {
      common = {
        default = [
          "gtk"
        ];
      };
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
      sway = {
        default = [
          "wlr"
          "gtk"
        ];
      };
    };
  };



  programs.sway.enable = true;
  programs.hyprland.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock = { };

  programs.zsh.enable = true;

  users.users.orbit = with pkgs; {
    initialPassword = "toor";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "docker" "audio" ];
    shell = zsh;
  };

  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    curl
    qemu
    qt5.qtwayland
  ];

  system.stateVersion = "24.11";
}

