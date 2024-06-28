{ pkgs, ... }@args: {
  home.packages = with pkgs; [
    # GUI
    firefox
    qbittorrent
    mpv
    zathura

    pulseaudio
    gnome.seahorse
    yazi
    file
    killall

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
    ripgrep
    fd

    pavucontrol

    zip
    unzip
    github-cli
    glow
    bear
    axel

    delta
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
    ripdrag
  ];
}
