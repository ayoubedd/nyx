{ pkgs, ... }: {
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    source-han-sans
    source-han-sans-japanese
    source-han-serif-japanese
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Noto Serif" "Source Han Serif" ];
      sansSerif = [ "Noto Sans" "Source Han Sans" ];
    };
  };
}
