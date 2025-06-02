{ pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    inputs.devenv.outputs.packages.x86_64-linux.default

    # Nix stuff
    nix-index
    nix-tree
    comma
    rclone
    atuin

    f2

    # docker-buildx
    lazydocker

    poppler
    ueberzugpp
    resvg
    imagemagick

    # GUI
    qbittorrent

    bandwhich

    mpv
    ripdrag
    pavucontrol
    seahorse
    gnome-software

    lsof

    httplz
    tokei
    whois

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
}
