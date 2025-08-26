{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.nwg-piotr;
in
{
  options = {
    programs.nwg-piotr = {
      enable = lib.mkEnableOption { };

      style = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "style config to be put in style.css";
      };

      config = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.attrs);
        default = null;
        description = "config to be put in bar.json";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ nwg-bar ];

    xdg.configFile."nwg-bar/bar.json" = {
      enable = cfg.config != null;
      text = lib.mkForce (builtins.toJSON cfg.config);
    };

    xdg.configFile."nwg-bar/style.css" = {
      enable = cfg.style != null;
      text = lib.mkForce cfg.style;
    };
  };
}
