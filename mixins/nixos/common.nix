{ pkgs, ... }: {
  imports = [
    ./nix.nix
    ./networking.nix
    ./bluethooth.nix
    ./services.nix
    ./audio.nix
    ./users.nix
    ./power.nix
    ./sysctl.nix
    ./fs.nix
    ./documentation.nix
  ];

  # System packages
  environment.systemPackages = with pkgs; [ neovim git curl qt5.qtwayland ];

  programs.nix-ld.enable = true;
  security.rtkit.enable =
    true; # For processs niceness and priority adjusment through dbus, used by browsers.

  time.hardwareClockInLocalTime = false;

  # services.ananicy = {
  #   enable = true;
  #   package = pkgs.ananicy-cpp;
  #   rulesProvider = pkgs.ananicy-rules-cachyos;
  # };

  environment.homeBinInPath = true;
  fonts.enableDefaultPackages = true;

  programs.dconf.enable = true;
  hardware.enableAllFirmware = true;
  programs.gnupg.agent.enable = true;
}

