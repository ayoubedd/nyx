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
    ./quietboot.nix
    ./local.nix
  ];

  # System packages
  environment.systemPackages = with pkgs; [
    neovim
    git
    curl
    qt5.qtwayland
    qt6.qtwayland
  ];

  programs.nix-ld.enable = true;

  security.rtkit.enable = true;

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  environment.homeBinInPath = true;
  fonts.enableDefaultPackages = true;

  programs.dconf.enable = true;
  hardware.enableAllFirmware = true;
  programs.gnupg.agent.enable = true;
}
