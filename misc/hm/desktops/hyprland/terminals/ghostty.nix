{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-size = 12;
      font-family = [ "JetBrainsMono Nerd Font" ];
      theme = "theme";
      async-backend = "io_uring";
      window-padding-x = "6";
      window-padding-y = "6";
      clipboard-read = "ask";
      clipboard-write = "ask";
      right-click-action = "copy-or-paste";
      keybind = [
        "ctrl+h=goto_split:left"
        "ctrl+l=goto_split:right"
      ];
    };
  };

}
