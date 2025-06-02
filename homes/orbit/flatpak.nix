{ ... }: {
  services.flatpak.packages = [{
    appId = "io.github.fizzyizzy05.binary";
    origin = "flathub";
  }];
}
