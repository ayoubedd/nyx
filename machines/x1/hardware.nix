{
  lib,
  pkgs,
  modulesPath,
  config,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../misc/nixos/hardware/intel.nix
  ];

  boot.kernelParams = [
    "nowatchdog"
    "kernel.nmi_watchdog=0"
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  boot.kernelModules = [
    "kvm-intel"
    "acpi_call"
  ];

  boot.blacklistedKernelModules = [
    "iTCO_wdt"
    "i915"
    "intel_oc_wdt"
    "nxp_nci_i2c"
    "nxp_nci"
    "nfc"
  ];

  boot.loader = {
    systemd-boot = {
      enable = lib.mkForce false;
      configurationLimit = 20;
      editor = false;
    };
    efi.canTouchEfiVariables = true;
  };

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.kernel.sysctl = {
    "fs.xfs.xfssyncd_centisecs" = 10000; # increase writeback interval
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
