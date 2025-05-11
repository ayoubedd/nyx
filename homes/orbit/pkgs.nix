{ pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    # Nix stuff
    nix-index
    nix-tree
    comma
    vlc
    rclone
    atuin
    inputs.sherlock.packages.x86_64-linux.default

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

    inputs.devenv.outputs.packages.x86_64-linux.default

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
