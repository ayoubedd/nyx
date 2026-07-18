{
  config,
  stateVersion,
  inputs,
  ...
}:
{

  imports = with inputs; [
    vicinae.homeManagerModules.default
    stylix.homeModules.stylix
    nur.modules.homeManager.default
    nix-flatpak.homeManagerModules.nix-flatpak
    eilmeldung.homeManager.default

    ../../../../modules/hm

    ./pkgs.nix
    ./misc.nix
    ./flatpak.nix

    ./git.nix

    ../../../../misc/hm/desktops/hyprland

  ];

  news.display = "silent";

  home.username = "orbit";
  home.homeDirectory = "/home/orbit";

  programs.home-manager.enable = true;

  home.file."${config.home.homeDirectory}/Pictures/Wallpapers" = {
    source = ../../../../assets/images/wallpapers;
    recursive = true;
  };

  programs.eilmeldung = {
    enable = true;
    # for HEAD of main
    #package = eilmeldung.packages.x86_64-linux.eilmeldung-git;

    settings = {
      refresh_fps = 60;
      article_scope = "unread";

      theme = {
        color_palette = {
          background = "#1e1e2e";
          # ...
        };
      };

      input_config.mappings = {
        "q" = [ "quit" ];
        "j" = [ "down" ];
        "k" = [ "up" ];
        "g g" = [ "gotofirst" ];
        "G" = [ "gotolast" ];
        "o" = [
          "open"
          "read"
          "nextunread"
        ];
      };

      feed_list = [
        "query: \"Today Unread\" today unread"
        "query: \"Today Marked\" today marked"
        "feeds"
        "* categories"
        "tags"
      ];
    };
  };

  home.stateVersion = stateVersion;
}
