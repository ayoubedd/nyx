{ pkgs, ... }@args: {
  home.packages = with pkgs; [
    # GUI
    firefox
    qbittorrent
    mpv
    ripdrag
    zathura
    pavucontrol
    gnome.seahorse

    # CMD
    yazi
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
}
