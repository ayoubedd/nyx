{ pkgs, ... }: {
  # Services
  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${pkgs.sway}/bin/sway";
          user = "greeter";
        };
      };
    };
  };
}
