{ pkgs, ... }:
let
  # The one place that picks the tuned profile from the power source:
  #   AC      -> x1-balanced
  #   battery -> x1-battery-balanced
  #
  # Runs at boot, when the AC state changes (udev), and after resume. It only
  # switches when the AC state actually differs from the last one it applied,
  # so a profile chosen by hand (dashboard Power page / `tuned-adm profile`)
  # stays until the charger is next plugged in or pulled, and duplicate or
  # spurious events are no-ops. `--force` applies regardless.
  #
  # (Hyprland animations off on battery is done in the session by quickshell:
  # misc/hm/desktops/hyprland/quickshell/config/services/PowerSaver.qml.)
  x1-power-profile = pkgs.writeShellScriptBin "x1-power-profile" ''
    set -eu
    state=/run/x1-power-profile
    online=$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo 1)
    last=$(cat "$state" 2>/dev/null || echo none)

    if [ "''${1:-}" != "--force" ] && [ "$online" = "$last" ]; then
      echo "AC online=$online unchanged, keeping the current profile"
      exit 0
    fi

    if [ "$online" = 1 ]; then
      profile=x1-balanced
    else
      profile=x1-battery-balanced
    fi
    ${pkgs.tuned}/bin/tuned-adm profile "$profile"
    echo "$online" > "$state"
    echo "AC online=$online -> $profile"
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

  # services.irqbalance.enable = true; # disabled cuz, cachyos kernel prefer last used cpu for cache locality

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
      # Off: with dynamic tuning, tuned's cpu plugin keeps a 100us PM QoS
      # latency request (/dev/cpu_dma_latency) whenever load is above its
      # threshold. This CPU's deep idle states take 253us (C7s) and 1048us
      # (C10) to exit, so they were forbidden and cores idled ~94% in C1,
      # keeping the package out of PC8/PC10 (several watts at idle).
      dynamic_tuning = false;
      reapply_sysctl = false;
    };

    # No tuned-ppd: it switched profiles on battery events too and fought
    # with manual choices. x1-power-profile (above) owns AC-based switching.
    ppdSupport = false;

    profiles = {
      common = {
        misc = {
          type = "sysfs";
          "/sys/power/mem_sleep" = "deep";

          # disable wake-on-lan
          "/sys/class/net/wlp0s20f3/device/power/wakeup" = "disabled";

          # Battery thresholds: stop charging at 85%, resume below 75%.
          # Keeps the (already worn, ~71% health) battery out of the
          # high-voltage range that ages it fastest. For a long trip, charge
          # to full once with:
          #   echo 100 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold
          # (reset to 85 by the next tuned profile switch / reboot).
          "/sys/class/power_supply/BAT0/charge_control_start_threshold" = 75;
          "/sys/class/power_supply/BAT0/charge_control_end_threshold" = 85;

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

          "/sys/devices/system/cpu/cpuidle/current_governor" = "teo";
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
          sampling_down_factor = 100;
        };

        acpi.platform_profile = "performance";
        usb.autosuspend = 0;
        audio.timeout = 0;

        cpu_dynamic_boost = {
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
          governor = "powersave";
          energy_perf_bias = "balance-power";
          energy_performance_preference = "balance_power";
          min_perf_pct = 0;
          max_perf_pct = 100;
          boost = 1;
          no_turbo = 0;
          sampling_down_factor = 1;
        };

        acpi.platform_profile = "balanced";
        usb.autosuspend = 0;
        audio.timeout = 0;

        cpu_dynamic_boost = {
          type = "sysfs";
          "/sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost" = 1;
        };

        gpu = {
          type = "sysfs";
          path = "/sys/class/drm/card1/";
          devices_udev_regex = ".*card1.*";
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_min_freq_mhz" = 100;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_max_freq_mhz" = 600;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/rps_boost_freq_mhz" = 700;
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/slpc_power_profile" = "base";
          "/sys/class/drm/card1/device/drm/card1/gt/gt0/slpc_ignore_eff_freq" = 1;
        };

        uncore = {
          type = "sysfs";
          path = "/sys/devices/system/cpu/intel_uncore_frequency";
          "/sys/devices/system/cpu/intel_uncore_frequency/package_00_die_00/min_freq_khz" = 400000;
          "/sys/devices/system/cpu/intel_uncore_frequency/package_00_die_00/max_freq_khz" = 2000000;
        };

        aspm = {
          type = "sysfs";
          path = "/sys/module/pcie_aspm";
          "/sys/module/pcie_aspm/parameters/policy" = "default";
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
        };

        acpi.platform_profile = "low-power";
        usb.autosuspend = 1;

        cpu_dynamic_boost = {
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
          energy_perf_bias = "power";
          energy_performance_preference = "power";
          min_perf_pct = 0;
          max_perf_pct = 50; # Strict clamp to keep the laptop completely silent and ice-cold
          boost = 0;
          no_turbo = 1;
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

  # AC-based profile switching (replaces the acpid handler: ThinkPad firmware
  # also raises ac_adapter events for thermal/lap-detect changes, and acpid
  # never ran at boot, so booting on battery kept the AC profile).
  systemd.services.x1-power-profile = {
    description = "Select the tuned profile for the current power source";
    after = [ "tuned.service" ];
    requires = [ "tuned.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${x1-power-profile}/bin/x1-power-profile";
    };
  };

  # Charger plugged / unplugged.
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="AC", ACTION=="change", RUN+="${pkgs.systemd}/bin/systemctl start --no-block x1-power-profile.service"
  '';

  # Plugged / unplugged while asleep (udev may not report it).
  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl start --no-block x1-power-profile.service
  '';

  services.throttled = {
    enable = true;
    extraConfig = ''
      [GENERAL]
      Enabled: True
      Autoreload: True

      [AC]
      # How often to override Lenovo's controller
      Update_Rate_s: 5
      # Sustained power limit (PL1)
      PL1_Tdp_W: 15
      PL1_Duration_s: 28
      # Short burst power limit (PL2)
      PL2_Tdp_W: 25
      PL2_Duration_S: 0.002
      # Max temperature before thermal throttling
      Trip_Temp_C: 90

      [BATTERY]
      Update_Rate_s: 5
      # Lower sustained limit unplugged: long loads (builds, video calls)
      # trade a little speed for less heat and drain. Bursts stay at 25 W.
      PL1_Tdp_W: 12
      PL1_Duration_s: 28
      PL2_Tdp_W: 25
      PL2_Duration_S: 0.002
      Trip_Temp_C: 85
    '';
  };

  # `sudo x1-power-profile --force` re-applies the automatic choice.
  environment.systemPackages = [ x1-power-profile ];
}
