{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # GUI
    qbittorrent
    pavucontrol
    seahorse
    gparted
    exfatprogs # needed for exfat/fat support within gparted

    # Misc
    bandwhich
    snitch
    lsof
    traceroute
    f2
    whois
    ncdu
    duf
    s-tui
    tokei
    binsider
    rclone
    cfspeedtest
    nvtopPackages.intel
    comma
    nix-index
    nix-tree
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
    nettools
    nftables
    sof-firmware
    bind # for dig
    yt-dlp
    devenv
    intel-gpu-tools
    powertop
    just
  ];
}
