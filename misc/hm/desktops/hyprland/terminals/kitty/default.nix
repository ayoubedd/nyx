{ config, ... }:
let
  # The stylix scheme (theming.nix). stylix's own kitty target stays off: it
  # would also set the font, and its template maps the bright colours
  # differently. This keeps kitty's mapping, just from the scheme.
  c = config.lib.stylix.colors.withHashtag;
in
{
  programs.kitty = {
    enable = true;

    settings = {
      foreground = c.base05;
      background = c.base00;
      selection_foreground = c.base00;
      selection_background = c.base05;
      url_color = c.base0C;
      cursor = c.base05;
      cursor_text_color = c.base00;

      active_tab_foreground = c.base00;
      active_tab_background = c.base0D;
      inactive_tab_foreground = c.base05;
      inactive_tab_background = c.base02;

      # normal / bright
      color0 = c.base00; # black
      color8 = c.base03;
      color1 = c.base08; # red
      color9 = c.base0F;
      color2 = c.base0B; # green
      color10 = c.base0B;
      color3 = c.base0A; # yellow
      color11 = c.base09;
      color4 = c.base0D; # blue
      color12 = c.base0D;
      color5 = c.base0E; # magenta
      color13 = c.base0E;
      color6 = c.base0C; # cyan
      color14 = c.base09;
      color7 = c.base05; # white
      color15 = c.base07;
    };

    extraConfig = builtins.readFile ./config/kitty.conf;
  };
}
