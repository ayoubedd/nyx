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

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];

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
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.editor = false;
    systemd-boot.memtest86.enable = true;
    systemd-boot.consoleMode = "1";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
