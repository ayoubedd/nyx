{
  config,
  pkgs,
  # lo-pkgs,
  host,
  ...
}:
{

  imports = [
    # import home manager custom modules
    ../../../../modules/hm

    ../../common

    # Hyprland config
    ./hyprland.nix

    # Fonts and GTK theming
    ./fonts.nix
    ./theming.nix

    # XDG stuff
    ./xdg.nix

    # Applets
    ./applets
    ./quickshell
    ./services.nix

    ./browsers/librewolf.nix
    # ./terminals/alacritty
    # ./terminals/ghostty.nix
    ./terminals/kitty
    ./zsh
    ./mpv.nix
    ./imv.nix
    ./zathura.nix

    ./nvim

    ./device/${host}
  ];

  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  home.packages = with pkgs; [
    # lo-pkgs.realod-failed-services
    wl-clipboard
    wl-color-picker
    hyprpicker
    slurp
    grim
    satty # screenshot editor (quickshell Screenshot.qml "Edit")
    wofi-emoji
    jq
    wl-clip-persist
    brightnessctl
    pulseaudio
  ];
}
