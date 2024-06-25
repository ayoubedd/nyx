{ pkgs, ... }@args: {
  home.packages = with pkgs; [
    # GUI
    firefox
    qbittorrent
    mpv
    zathura

    (ldm.override { mountPath = "/mnt/"; })

    yazi

    # CMD
    btop
    vim
    wget
    curl
    bat
    git
    tree
    bat
    eza
    python3

    pavucontrol

    zip
    unzip
    github-cli
    glow
    bear
    axel

    delta
    #papirus-icon-theme
    fprintd
    fx
    thermald
    lazygit
    lynx
    exiftool
    atool
    nettools
    p7zip
    nftables
    sof-firmware
    wireguard-tools
    procps
    catppuccin-cursors.mochaMauve
    ripdrag
    ldm
    overskride
  ];
}
