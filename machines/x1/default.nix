{
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    ../../misc/nixos/common
    ../../misc/nixos/apps/qemu.nix
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
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit inputs;
    host = config.networking.hostName;
    stateVersion = config.system.stateVersion;
  };

  nix.distributedBuilds = lib.mkForce true;
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [
    {
      hostName = "10.1.2.107";
      sshUser = "nixbuilder";
      sshKey = "/root/.ssh/id_rsa";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      # Number of cores the server should dedicate to a build
      maxJobs = 12;
      # Tells Nix this machine is fast (higher number = preferred)
      speedFactor = 20000;
      # Required features to build the Linux kernel
      supportedFeatures = [
        "big-parallel"
        "kvm"
      ];
    }
  ];

  system.stateVersion = "26.05";
}
