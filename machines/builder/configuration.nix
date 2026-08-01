{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "nix-builder-1"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "Africa/Casablanca";

  users.users.leo = {
    isNormalUser = true;
    hashedPassword = "$6$rounds=10000$VXEQMcd5hlHAT.Gv$rgyfpVKRVgmLH5ggI5vGqPB.zXh1b3qYh1L5nNloSxUVXysWEiYzBCWw50dGOPhxp50b4xkTDckxA4EEjoP.V1";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      git
      tree
      htop
      btop
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMwnEWxx6AA4Cgws5rCd+3Jb8H9Bq8u24AxVCOXvW2Dn"
    ];
  };

  users.users.nixbuilder = {
    isSystemUser = true;
    shell = pkgs.bash;
    description = "Remote Nix Builder";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEYDO0g7cCEyEIvb8DqNQHhG4d6uMeEeBrRGbEQzhdYG5PzsK5XUBTORYpZMUkv5schIXeHZViT0oNqSezTtvtMz6L1gqMFHJHv7/PiVhTKgTrOUyK+ksOIWkrfYhwdeza2eTz2ptnugTaOGcwp4E2D5y2lqjwl3nxg6iqHlO3So+hsVFVH76xlSXsIfFZ2TiUV83+vI/3pkZWR873RUcWhvJG/xG9Nok81XK3X+5tydcIHBBy8Xka7v4RchzxPCK8FnVsK5ugNp1neUQLPnuTvP7XY0Dz9t/dl1GsXQVHq8HuYytYDcPBGzz6MlQN8ZQYt6ahS1uOdWrQkLfeHUCFORR6FIqr6/ZkdqrInITePVsNpzopzdeQ/Q//1+9PS57xN4MuUk9ipCNrhvt3wcfvTJQO4NshgdkJEEn9TwvOwOp0ULQNKX/szWmR7pgZfRTpaUI2IkSULCKTqkSYgNLcylKR+sdC3j0xYvorIH3YJz13USRX2c3+MFcYGpsRTT8="
    ];
    group = "nixbuilder";
  };

  users.groups.nixbuilder = { };

  nix.settings = {
    trusted-users = [
      "root"
      "nixbuilder"
    ];

    extra-substituters = [
      "https://cache.xinux.uz"
      "https://attic.xuyh0120.win/lantian"
    ];

    extra-trusted-public-keys = [
      "cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };

  services.openssh.enable = true;

  system.stateVersion = "26.05";
}
