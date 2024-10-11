{ pkgs, ... }: {
  home.packages = with pkgs; [ zathura ];


  home.file.".config/zathura/zathurarc" = {
    enable = true;
    text = ''
      # Zathura configuration file
      # See man `man zathurarc'

      set selection-clipboard clipboard

      # Open document in fit-width mode by default
      set adjust-open "best-fit"

      # One page per row by default
      set pages-per-row 1

      #stop at page boundries
      set scroll-page-aware "true"
      set smooth-scroll "true"
      set scroll-full-overlap 0.01
      set scroll-step 100

      #zoom settings
      set zoom-min 10
      set guioptions ""

      set font "Noto Sans Mono 15"

      set render-loading "false"
      set scroll-step 50
      unmap f
      map f toggle_fullscreen
      map [fullscreen] f toggle_fullscreen
    '';
  };
}
