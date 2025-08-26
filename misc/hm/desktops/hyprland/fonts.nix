{ pkgs, ... }:
{
  home.packages = with pkgs; [
    noto-fonts
    # noto-fonts-cjk
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
    source-han-sans
    source-han-sans-japanese
    source-han-serif-japanese
    cantarell-fonts
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [
        "Noto Sans Mono"
        "Noto Naskh Arabic UI"
        "Noto Sans Arabic"
      ];
      serif = [
        "Noto Serif"
        "Noto Naskh Arabic UI"
        "Noto Sans Arabic"
      ];
      sansSerif = [
        "Noto Sans"
        "Noto Naskh Arabic UI"
        "Noto Sans Arabic"
      ];
    };
  };
}
