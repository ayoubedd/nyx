{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  services.flatpak.packages = [
    "com.obsproject.Studio"
    "com.brave.Browser"
    "com.spotify.Client"
    "dev.vencord.Vesktop"
    "com.github.tchx84.Flatseal"
    "com.getpostman.Postman"
    "org.inkscape.Inkscape"
    "org.gimp.GIMP"
  ];

  services.flatpak.uninstallUnmanaged = true;

  services.flatpak.overrides = {
    "com.getpostman.Postman".Context.sockets = [
      "wayland"
      "!x11"
      "!fallback-x11"
    ];

    "dev.vencord.Vesktop".Context.sockets = [
      "wayland"
      "!x11"
      "!fallback-x11"
    ];

  };
}
