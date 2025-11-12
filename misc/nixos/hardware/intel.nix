{
  pkgs,
  lib,
  config,
  ...
}:
{
  boot.kernelParams = [
    "intel_pstate=enable"
    "i915.fastboot=1"
    "i915.enable_psr=2"
    "i915.enable_psr2_sel_fetch=1"
    "i915.enable_guc=3"
    "i915.enable_fbc=1"
    "i915.enable_gvt=1"
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
      intel-compute-runtime
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
