{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # GUI
    qbittorrent
    pavucontrol
    seahorse
    gparted
    exfatprogs # needed for exfat/fat support within gparted
    zed-editor

    # Misc
    # vm-curator
    rustnet
    lsof
    traceroute
    f2
    whois
    ncdu
    duf
    tokei
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
    axel
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
    dig
    yt-dlp
    devenv
    powertop
  ];
}
