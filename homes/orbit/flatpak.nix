{ ... }: {
  services.flatpak.packages = [
    "com.obsproject.Studio"
    "com.brave.Browser"
    "com.spotify.Client"
    "dev.vencord.Vesktop"
    "com.github.tchx84.Flatseal"
    "com.getpostman.Postman"
  ];

  services.flatpak.uninstallUnmanaged = true;

  services.flatpak.overrides = {
    "com.getpostman.Postman".Context.sockets =
      [ "wayland" "!x11" "!fallback-x11" ];

    "dev.vencord.Vesktop".Context.sockets =
      [ "wayland" "!x11" "!fallback-x11" ];

  };
}

