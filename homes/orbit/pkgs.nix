{ pkgs, ... }@args: {
  home.packages = with pkgs; [
    # GUI
    qbittorrent
    mpv
    ripdrag
    zathura
    pavucontrol
    seahorse
    gnome.gnome-software

    devenv
    httplz
    tokei

    # CMD
    yazi
    # ueberzugpp
    file
    killall
    btop
    wget
    curl
    axel
    git
    tree
    bat
    eza
    ripgrep
    fd
    procps
    zip
    unzip
    p7zip
    github-cli
    glow
    delta
    lazygit
    exiftool
    atool
    nettools
    nftables
    sof-firmware
    bind # for dig
  ];

  programs.direnv = {
    enable = true;
  };
}
