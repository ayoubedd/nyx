{ pkgs, ... }:
let
  awk = "${pkgs.gawk}/bin/awk";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  hypr-powersave = pkgs.writeScriptBin "hypr-powersave" ''
    #!${pkgs.bash}/bin/bash
    # 1. Dynamically find the username and UID of the active graphical session
    USER_NAME=$(stat -c '%U' /dev/dri/card1 2>/dev/null)

    if [ -z "$USER_NAME" ] || [ "$USER_NAME" = "root" ]; then
      USER_NAME=$(who | ${awk} '{print $1}' | head -n1)
    fi

    if [ -z "$USER_NAME" ]; then
      USER_NAME=$(id -nu 1000)
    fi

    USER_ID=$(id -u "$USER_NAME")
    XDG_RUNTIME_DIR="/run/user/$USER_ID"

    # 2. Extract the active Hyprland instance signature from the runtime directory
    HYPR_SIG=$(ls -t "$XDG_RUNTIME_DIR/hypr/" 2>/dev/null | grep -E '^[a-f0-9]+_[0-9]+_[0-9]+$' | head -n1)

    if [ -z "$HYPR_SIG" ]; then
      HYPR_SIG=$(ls -t "$XDG_RUNTIME_DIR/hypr/" 2>/dev/null | grep -v "\.sock" | head -n1)
    fi

    if [ -z "$HYPR_SIG" ]; then
      echo "No active Hyprland instance signature found."
      exit 0 # Exit with 0 so the systemd service doesn't report a "failed" state if no one is logged in
    fi

    # 3. Check the AC status (0 = battery, 1 = plugged in)
    STATUS=$(cat /sys/class/power_supply/AC/online)

    # Note: We explicitly path to hyprctl from pkgs here or assume it's in the environment.
    # To be perfectly safe inside systemd, let's use the absolute path if available, 
    # but since it's a user bin, it's safer to just run it as the user.
    if [ "$STATUS" -eq 0 ]; then
      env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" HYPRLAND_INSTANCE_SIGNATURE="$HYPR_SIG" ${hyprctl} eval 'hl.config({ animations = { enabled = false } })'
    else
      env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" HYPRLAND_INSTANCE_SIGNATURE="$HYPR_SIG" ${hyprctl} eval 'hl.config({ animations = { enabled = true } })'
    fi
  '';
in
{
  boot.kernelParams = [
    "intel_pstate=enable"

    # Net
    "iwlwifi.power_save=true"
    "iwlwifi.power_level=5"
    "iwlmvm.power_scheme=3"

    # Storage
    "nvme_core.default_ps_max_latency_us=10000"

    # Intel i915 Graphics
    "i915.enable_fbc=1"
    "i915.enable_psr=1"
    "i915.enable_guc=3"

    # Force PCIe Runtime Power Management across the board
    "pcie_aspm=force"

    "rcutree.enable_rcu_lazy=1"
  ];

  services.irqbalance.enable = true;

  services.thermald = {
    enable = true;
    ignoreCpuidCheck = true;
  };

  services.pipewire.extraConfig.pipewire."99-input-denoiser" = {
    "context.properties" = {
      "default.clock.min-quantum" = 1024; # Reduces wakeups
    };
  };
  # Ensure wireplumber suspends idle nodes
  services.pipewire.wireplumber.extraConfig."10-power-clean" = {
    "monitor.bluez.properties" = {
      "bluez5.suspend-on-idle" = true;
    };
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
          elevator = "none";
        };
      };

      x1-performance = {
        main.include = "common";

        cpu = {
          governor = "performance";
          energy_perf_bias = "performance";
          energy_performance_preference = "performance";
          min_perf_pct = 0; # ALLOW the CPU to drop frequency at idle so it can cool down
          max_perf_pct = 100;
          boost = 1;
          no_turbo = 0;

          # Thermals-safe adjustments:
          sampling_down_factor = 1; # Don't delay down-clocking; let it drop immediately when done
          pm_qos_resume_latency_us = 0; # DO NOT disable C-states; the laptop needs them to prevent cooking
          force_latency = "cstate.name:C1|None"; # Minimal target without blocking deeper package sleep
        };

        acpi.platform_profile = "performance";
        usb.autosuspend = 0;
        audio.timeout = 0;

        cpu_dynamic_boot = {
          type = "sysfs";
          "/sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost" = 1;
        };

        gpu = {
          type = "sysfs";
          path = "/sys/class/drm/card1/";
          devices_udev_regex = ".*card1.*";
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_min_freq_mhz" = 400;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_max_freq_mhz" = 1300;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_boost_freq_mhz" = 1300;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/slpc_power_profile" = "base";
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/slpc_ignore_eff_freq" = 0;
        };

        uncore = {
          type = "sysfs";
          path = "/sys/devices/system/cpu/intel_uncore_frequency";
          "/sys/devices/system/cpu/intel_uncore_frequency/package_00_die_00/min_freq_khz" = 1000000;
          "/sys/devices/system/cpu/intel_uncore_frequency/package_00_die_00/max_freq_khz" = 3600000;
        };

        aspm = {
          type = "sysfs";
          path = "/sys/module/pcie_aspm";
          "/sys/module/pcie_aspm/parameters/policy" = "performance";
        };

        vm = {
          type = "sysctl";
          "vm.dirty_expire_centisecs" = 300;
          "vm.dirty_writeback_centisecs" = 1500;
        };
      };

      x1-balanced = {
        main.include = "common";

        cpu = {
          governor = "powersave|ondemand";
          energy_perf_bias = "balance-performance";
          energy_performance_preference = "balance_performance";
          min_perf_pct = 0;
          max_perf_pct = 100;
          boost = 1;
          no_turbo = 0;
          sampling_down_factor = 1;
          pm_qos_resume_latency_us = 0;
        };

        acpi.platform_profile = "balanced";
        usb.autosuspend = 0;
        audio.timeout = 0;

        cpu_dynamic_boot = {
          type = "sysfs";
          "/sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost" = 1;
        };

        gpu = {
          type = "sysfs";
          path = "/sys/class/drm/card1/";
          devices_udev_regex = ".*card1.*";
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_min_freq_mhz" = 100;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_max_freq_mhz" = 800;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_boost_freq_mhz" = 1000;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/slpc_power_profile" = "base";
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/slpc_ignore_eff_freq" = 0;
        };

        uncore = {
          type = "sysfs";
          path = "/sys/devices/system/cpu/intel_uncore_frequency";
          "/sys/devices/system/cpu/intel_uncore_frequency/package_00_die_00/min_freq_khz" = 400000;
          "/sys/devices/system/cpu/intel_uncore_frequency/package_00_die_00/max_freq_khz" = 3000000;
        };

        aspm = {
          type = "sysfs";
          path = "/sys/module/pcie_aspm";
          "/sys/module/pcie_aspm/parameters/policy" = "powersave";
        };

        sysctl_vm = {
          type = "sysctl";
          "vm.dirty_expire_centisecs" = 300;
          "vm.dirty_writeback_centisecs" = 1500;
        };
      };

      x1-battery-balanced = {
        main.include = "common";

        cpu = {
          governor = "powersave";
          energy_perf_bias = "balance-power";
          energy_performance_preference = "balance_power";
          min_perf_pct = 0;
          max_perf_pct = 60;
          boost = 0;
          no_turbo = 1;
          sampling_down_factor = 1;
          pm_qos_resume_latency_us = 0;
        };

        acpi.platform_profile = "low-power";
        usb.autosuspend = 1;

        cpu_dynamic_boot = {
          type = "sysfs";
          "/sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost" = 1;
        };

        gpu = {
          type = "sysfs";
          path = "/sys/class/drm/card1/";
          devices_udev_regex = ".*card1.*";
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_min_freq_mhz" = 100;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_max_freq_mhz" = 600;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_boost_freq_mhz" = 600;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/slpc_power_profile" = "power_saving";
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/slpc_ignore_eff_freq" = 1;
        };

        audio = {
          type = "sysfs";
          "/sys/module/snd_hda_intel/parameters/power_save_controller" = "Y";
        };

        audio = {
          timeout = 1;
          reset_controller = true;
        };

        uncore = {
          type = "sysfs";
          path = "/sys/devices/system/cpu/intel_uncore_frequency";
          "/sys/devices/system/cpu/intel_uncore_frequency/package_00_die_00/min_freq_khz" = 400000;
          "/sys/devices/system/cpu/intel_uncore_frequency/package_00_die_00/max_freq_khz" = 1800000;
        };

        aspm = {
          type = "sysfs";
          path = "/sys/module/pcie_aspm";
          "/sys/module/pcie_aspm/parameters/policy" = "powersave";
        };

        sysctl_vm = {
          type = "sysctl";
          "vm.dirty_expire_centisecs" = 5000;
          "vm.dirty_writeback_centisecs" = 3000;
        };
      };

      x1-powersave = {
        main.include = "common";

        cpu = {
          governor = "powersave";
          energy_perf_bias = "power"; # "performance", "balance-performance", "normal", "balance-power" and "power"
          energy_performance_preference = "power";
          min_perf_pct = 0;
          max_perf_pct = 50; # Strict clamp to keep the laptop completely silent and ice-cold
          boost = 0;
          no_turbo = 1;
          sampling_down_factor = 1;
          pm_qos_resume_latency_us = 0;
        };

        acpi.platform_profile = "low-power";
        usb.autosuspend = 1;

        cpu_dynamic_boost = {
          type = "sysfs";
          "/sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost" = 0;
        };

        gpu = {
          type = "sysfs";
          path = "/sys/class/drm/card1/";
          devices_udev_regex = ".*card1.*";
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_min_freq_mhz" = 100;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_max_freq_mhz" = 400;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_boost_freq_mhz" = 400;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/slpc_power_profile" = "power_saving";
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/slpc_ignore_eff_freq" = 1;
        };

        audio = {
          type = "sysfs";
          "/sys/module/snd_hda_intel/parameters/power_save_controller" = "Y";
        };

        audio = {
          timeout = 1;
          reset_controller = true;
        };

        uncore = {
          type = "sysfs";
          path = "/sys/devices/system/cpu/intel_uncore_frequency";
          "/sys/devices/system/cpu/intel_uncore_frequency/package_00_die_00/min_freq_khz" = 400000;
          "/sys/devices/system/cpu/intel_uncore_frequency/package_00_die_00/max_freq_khz" = 1000000;
        };

        aspm = {
          type = "sysfs";
          path = "/sys/module/pcie_aspm";
          "/sys/module/pcie_aspm/parameters/policy" = "powersupersave";
        };

        vm = {
          type = "sysctl";
          "vm.dirty_expire_centisecs" = 6000;
          "vm.dirty_writeback_centisecs" = 6000;
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

        ${hypr-powersave}/bin/hypr-powersave
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

  environment.systemPackages = [ hypr-powersave ];
}
