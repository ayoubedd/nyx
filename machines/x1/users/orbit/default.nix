{
  inputs,
  pkgs,
  config,
  ...
}:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  users.users.orbit = with pkgs; {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
    ]
    ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd"
    ++ lib.optional config.virtualisation.docker.enable "docker"
    ++ lib.optional config.networking.networkmanager.enable "networkmanager";
    hashedPasswordFile = config.sops.secrets.orbit_password.path;
    shell = zsh;
  };

  home-manager.users.orbit =
    { ... }:
    {
      imports = with inputs; [
        vicinae.homeManagerModules.default
        stylix.homeModules.stylix
        nur.modules.homeManager.default
        nix-flatpak.homeManagerModules.nix-flatpak
        ./home.nix
      ];
    };
}
