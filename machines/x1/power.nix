{ pkgs, ... }:
{
  boot.kernelParams = [
    "iwlwifi.power_save=true"
    "iwlwifi.power_level=5"
    "iwlmvm.power_scheme=3"
  ];

  services.irqbalance.enable = true;

  services.thermald = {
    enable = true;
    ignoreCpuidCheck = true;
  };

  services.tlp.enable = false;

  services.tuned = {
    enable = true;

    settings = {
      dynamic_tuning = true;
      reapply_sysctl = false;
    };

    ppdSettings = {
      main = {
        default = "balanced";
      };
      battery = {
        balanced = "x1-battery-balanced";
      };
      profiles = {
        balanced = "x1-balanced";
        performance = "x1-performance";
        power-saver = "x1-powersave";
      };
    };

    profiles = {
      common = {
        misc = {
          type = "sysfs";
          "/sys/power/mem_sleep" = "deep";

          # disable wake-on-lan
          "/sys/class/net/wlp0s20f3/device/power/wakeup" = "disabled";

          # Battery thresholds
          "/sys/class/power_supply/BAT0/charge_control_start_threshold" = 75;
          "/sys/class/power_supply/BAT0/charge_control_end_threshold" = 80;

          # Active governor
          "/sys/devices/system/cpu/intel_pstate/status" = "active";

          "/sys/bus/pci/devices/0000:00:08.0/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:1f.0/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:04.0/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:14.3/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:1f.5/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:00.0/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:14.2/power/control" = "auto";
          "/sys/bus/pci/devices/0000:04:00.0/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:0a.0/power/control" = "auto";
        };

        disk = {
          devices = "nvme0n1";
          readahead = 4096;
          elevator = "kyber";
        };
      };

      x1-performance = {
        main.include = "common";

        cpu = {
          governor = "performance";
          energy_perf_bias = "performance";
          energy_performance_preference = "performance";
          min_perf_pct = 0;
          max_perf_pct = 100;
          force_latency = 99;
          no_turbo = 0;
          boost = 1;
        };

        acpi = {
          platform_profile = "performance";
        };

        usb = {
          autosuspend = 0;
        };

        sysfs_cpu = {
          type = "sysfs";
          "/sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost" = 1;
        };

        sysfs_gpu = {
          type = "sysfs";
          path = "/sys/class/drm/card0/";
          devices_udev_regex = ".*card0.*";
          "/sys/class/drm/card0/device/tile0/gt0/freq0/min_freq" = 400;
          "/sys/class/drm/card0/device/tile0/gt0/freq0/max_freq" = 1300;
          "/sys/class/drm/card0/device/tile0/gt0/freq0/power_profile" = "base";
        };

        sysfs_audio = {
          type = "sysfs";
          "/sys/module/snd_hda_intel/parameters/power_save_controller" = "N";
          "/sys/module/snd_hda_intel/parameters/power_save" = "0";
        };
      };

      x1-balanced = {
        main.include = "common";

        cpu = {
          governor = "powersave";
          energy_perf_bias = "balance-performance";
          energy_performance_preference = "balance_performance";
          no_turbo = 0;
          boost = 1;
        };

        acpi = {
          platform_profile = "balanced";
        };

        usb = {
          autosuspend = 0;
        };

        sysfs_cpu = {
          type = "sysfs";
          "/sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost" = 1;
        };

        sysfs_gpu = {
          type = "sysfs";
          path = "/sys/class/drm/card0/";
          devices_udev_regex = ".*card0.*";
          "/sys/class/drm/card0/device/tile0/gt0/freq0/min_freq" = 100;
          "/sys/class/drm/card0/device/tile0/gt0/freq0/max_freq" = 700;
          "/sys/class/drm/card0/device/tile0/gt0/freq0/power_profile" = "base";
        };

        sysfs_audio = {
          type = "sysfs";
          "/sys/module/snd_hda_intel/parameters/power_save_controller" = "N";
          "/sys/module/snd_hda_intel/parameters/power_save" = "0";
        };
      };

      x1-battery-balanced = {
        main.include = "common";

        cpu = {
          governor = "powersave";
          energy_perf_bias = "balance-power";
          energy_performance_preference = "balance_power";
          no_turbo = 0;
          boost = 1;
        };

        acpi = {
          platform_profile = "balanced";
        };

        usb = {
          autosuspend = 0;
        };

        sysfs_cpu = {
          type = "sysfs";
          "/sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost" = 1;
        };

        sysfs_gpu = {
          type = "sysfs";
          path = "/sys/class/drm/card0/";
          devices_udev_regex = ".*card0.*";
          "/sys/class/drm/card0/device/tile0/gt0/freq0/min_freq" = 100;
          "/sys/class/drm/card0/device/tile0/gt0/freq0/max_freq" = 500;
          "/sys/class/drm/card0/device/tile0/gt0/freq0/power_profile" = "base";
        };

        sysfs_audio = {
          type = "sysfs";
          "/sys/module/snd_hda_intel/parameters/power_save_controller" = "N";
          "/sys/module/snd_hda_intel/parameters/power_save" = "0";
        };
      };

      x1-powersave = {
        main.include = "common";

        cpu = {
          governor = "powersave";
          energy_perf_bias = "power";
          energy_performance_preference = "power";
          no_turbo = 1;
          boost = 0;
        };

        acpi = {
          platform_profile = "low-power";
        };

        usb = {
          autosuspend = 1;
        };

        sysfs_cpu = {
          type = "sysfs";
          "/sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost" = 0;
        };

        sysfs_gpu = {
          type = "sysfs";
          path = "/sys/class/drm/card0/";
          devices_udev_regex = ".*card0.*";
          "/sys/class/drm/card0/device/tile0/gt0/freq0/min_freq" = 100;
          "/sys/class/drm/card0/device/tile0/gt0/freq0/max_freq" = 400;
          "/sys/class/drm/card0/device/tile0/gt0/freq0/power_profile" = "power_saving";
        };

        sysfs_audio = {
          type = "sysfs";
          "/sys/module/snd_hda_intel/parameters/power_save_controller" = "Y";
          "/sys/module/snd_hda_intel/parameters/power_save" = "10";
        };
      };
    };

  };

  services.acpid = {
    enable = true;
    handlers.power_profile_switch = {
      # ac_adapter ACPI0003:00 00000080 00000000 # unplugging
      # ac_adapter ACPI0003:00 00000080 00000001 # plug-in
      action = /* sh */ ''
        vals=($1)  # space separated string to array of multiple values
        case ''${vals[3]} in
            00000000)
                ${pkgs.tuned}/bin/tuned-adm profile x1-battery-balanced
                ;;
            00000001)
                ${pkgs.tuned}/bin/tuned-adm profile x1-balanced
                ;;
            *)
                echo unknown >> /tmp/acpi.log
                ;;
        esac
      '';
      event = "ac_adapter/*";
    };
  };
}
