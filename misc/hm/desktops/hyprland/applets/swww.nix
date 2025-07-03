{ pkgs, config, ... }:
let
  writeShellScriptBin = pkgs.stdenv.mkDerivation {
    name = "reload-wallpaper";
    src = ../scripts;
    buildPhase = "";
    installPhase = ''
      mkdir -p $out/bin
      cp $src/reload-wallpaper $out/bin
    '';
  };

in {
  services.swww.enable = true;

  systemd.user.services.swww-wallpaper-reload = {
    Install = { WantedBy = [ config.wayland.systemd.target ]; };

    Unit = {
      ConditionEnvironment = "WAYLAND_DISPLAY";
      Description = "swww-wallpaper-reload";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
    };

    Service = {
      ExecStart = "${writeShellScriptBin}/bin/reload-wallpaper";
    };
  };
}
