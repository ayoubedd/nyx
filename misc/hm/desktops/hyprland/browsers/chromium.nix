{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;

    commandLineArgs = [
      "--ozone-platform-hint=wayland"
      "--enable-features=TouchpadOverscrollHistoryNavigation"
      "--disable-sync-preferences"
    ];

    dictionaries = with pkgs.hunspellDictsChromium; [
      en_US
      fr_FR
    ];

    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark reader
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # SponsorBlock
    ];
  };
}
