{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    inputs.devenv.outputs.packages.x86_64-linux.default

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

    # docker-buildx
    lazydocker

    # GUI
    qbittorrent

    bandwhich

    ripdrag
    pavucontrol
    seahorse

    lsof

    # httplz
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
  ];
}
