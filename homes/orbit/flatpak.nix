{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  services.flatpak.packages = [
    "com.brave.Browser"
    "com.github.tchx84.Flatseal"
    "org.inkscape.Inkscape"
    "org.gimp.GIMP"
  ];

  services.flatpak.uninstallUnmanaged = true;
}
