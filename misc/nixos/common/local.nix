{ lib, ... }: {
  time.timeZone = lib.mkDefault "Africa/Casablanca";
  time.hardwareClockInLocalTime = false;

  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
    extraLocales = lib.mkDefault [ "en_US.UTF-8/UTF-8" ];
  };

  location.provider = "geoclue2";
  services.automatic-timezoned.enable = true;
}
