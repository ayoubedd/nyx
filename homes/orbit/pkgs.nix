{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Nix stuff
    nix-index
    nix-tree
    comma
    rclone

    gparted
    exfatprogs

    binsider
    nvtopPackages.intel

    f2
    cfspeedtest

    # GUI
    qbittorrent

    bandwhich
    bluetui

    ripdrag
    pavucontrol
    seahorse

    lsof
    traceroute

    tokei
    whois

    # CMD
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
    yt-dlp
    devenv
    intel-gpu-tools
    powertop
    just
    direnv
    ncdu
    duf
  ];
}
