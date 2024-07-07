{ pkgs, ... }: {

  gtk = {
    enable = true;
    cursorTheme = {
      size = 24;
      name = "volantes_cursors";
      package = pkgs.volantes-cursors;
    };
  };

  home.pointerCursor = {
    size = 24;
    name = "volantes_cursors";
    package = pkgs.volantes-cursors;
    x11 = {
      enable = true;
      defaultCursor = "volantes_cursors";
    };
  };
}
