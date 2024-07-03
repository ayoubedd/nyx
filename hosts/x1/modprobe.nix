{ ... }: {
  environment.etc."modprobe.d/blacklist.conf".text = ''
    # Blacklist the Intel TCO Watchdog/Timer module
    blacklist iTCO_wdt
  '';
}
