{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    packages = [
      "page.codeberg.petsoi.words"
      "com.brave.Browser"
      "com.github.tchx84.Flatseal"
      "org.inkscape.Inkscape"
      "org.gimp.GIMP"
      "io.github.nokse22.trivia-quiz"
    ];

    update.auto.enable = false;
    uninstallUnmanaged = true;
  };

}
