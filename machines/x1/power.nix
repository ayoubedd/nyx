{ ... }: {
  services.thermald.enable = true;
  services.thermald.ignoreCpuidCheck = true;

  services.acpid = {
    enable = true;
    handlers.energy_perf_bias = {
      # ac_adapter ACPI0003:00 00000080 00000000 # unplugging
      # ac_adapter ACPI0003:00 00000080 00000001 # plug-in
      action = ''
        vals=($1)  # space separated string to array of multiple values
        case ''${vals[3]} in
            00000000)
                echo 15 | tee /sys/devices/system/cpu/cpu*/power/energy_perf_bias
                ;;
            00000001)
                echo 0 | tee /sys/devices/system/cpu/cpu*/power/energy_perf_bias
                ;;
            *)
                echo unknown >> /tmp/acpi.log
                ;;
        esac
      '';
      event = "ac_adapter/*";
    };
  };

  services.tlp = {
    enable = true;
    settings = {
      TLP_ENABLE = 1;

      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "active";

      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 40;

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;

      NMI_WATCHDOG = 0;

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      MEM_SLEEP_ON_AC = "deep";
      MEM_SLEEP_ON_BAT = "deep";

      DISK_DEVICES = "nvme0n1";

      AHCI_RUNTIME_PM_ON_AC = "on";
      AHCI_RUNTIME_PM_ON_BAT = "auto";

      AHCI_RUNTIME_PM_TIMEOUT = 15;

      INTEL_GPU_MIN_FREQ_ON_AC = 100;
      INTEL_GPU_MIN_FREQ_ON_BAT = 100;

      INTEL_GPU_MAX_FREQ_ON_AC = 1300;
      INTEL_GPU_MAX_FREQ_ON_BAT = 500;

      INTEL_GPU_BOOST_FREQ_ON_AC = 1300;
      INTEL_GPU_BOOST_FREQ_ON_BAT = 700;

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      WOL_DISABLE = "Y";

      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 10;

      SOUND_POWER_SAVE_CONTROLLER = "Y";

      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      USB_AUTOSUSPEND = 1;

      USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN = 0;

      RESTORE_DEVICE_STATE_ON_STARTUP = 0;

      DEVICES_TO_DISABLE_ON_STARTUP = "nfc";

      DEVICES_TO_ENABLE_ON_STARTUP = "wifi bluetooth";

      START_CHARGE_THRESH_BAT0 = 80;
      STOP_CHARGE_THRESH_BAT0 = 100;
    };
  };
}
