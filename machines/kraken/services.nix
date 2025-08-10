{ pkgs, lib, ... }: {
  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time";
          user = "greeter";
        };
      };
    };
  };

  services.openssh.enable = true;
  services.devmon.enable = lib.mkForce false; # reason: thunar takes care of it
}
