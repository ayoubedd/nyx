# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../misc/nixos/hardware/intel.nix
  ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.blacklistedKernelModules = [ "iTCO_wdt" ];

  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    "nmi_watchdog=0"
  ];

  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3df7578c-8353-4de7-a255-ad43d16fb67b";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B4B1-D6F5";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # fileSystems."/run/media/casa/hdd-1" = {
  #   device = "truenas-1.casa.ayoubedd.me:/mnt/hdd-1";
  #   fsType = "nfs";
  #   options = [ "nofail" "noatime" "nodiratime" ];
  # };
  #
  swapDevices = [ ];

  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = "\\xff\\xff\\xff\\xff\\x00\\x00\\x00\\x00\\xff\\xff\\xff";
    magicOrExtension = "\\x7fELF....AI\\x02";
  };

  boot.plymouth.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
