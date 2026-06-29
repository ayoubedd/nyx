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

  hardware.bluetooth.powerOnBoot = false;

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
    "tpm_crb"
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

    autoEnrollKeys = {
      enable = true;
    };

    measuredBoot = {
      enable = true;
      pcrs = [
        # --- Platform/Firmware Integrity (Highly Static) ---
        0 # Motherboard BIOS/UEFI firmware executable code
        1 # Motherboard BIOS/UEFI internal configuration settings
        2 # Option ROM code (e.g., physical GPU/RAID card firmware)
        # 3 # Option ROM configurations and settings

        # --- Bootloader Integrity ---
        # 4 # EFI Bootloader executable code (e.g., systemd-boot / GRUB binary)
        # 5 # Bootloader configuration files, variables, and partition data

        # --- Secure Boot & System Validation ---
        # 6 # Host platform power management and reset transitions
        7 # # Secure Boot enforcement state and internal certificate keys

        # --- Linux Kernel Integrity (Changes on every OS update) ---
        # 8 # Unused / Reserved
        # 9 # Linux kernel image and initrd/initramfs archive
        # 10 # IMA (Integrity Measurement Architecture) logs
        # 11 # Kernel boot parameters and systemd execution state
        # 12 # Linux kernel command line configuration arguments

        # --- Extended & Custom Policies ---
        # 13 # System extensions (sysexts) measurements
        # 14 # Shim bootloader signature policy profiles
        # 15 # Operating system base identity hashes / root images
        # 16 # Debugging interfaces and testing assertions
      ];
    };

    configurationLimit = 8;

    autoGenerateKeys.enable = true;
  };

  boot.kernel.sysctl = {
    "fs.xfs.xfssyncd_centisecs" = 10000; # increase writeback interval
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
