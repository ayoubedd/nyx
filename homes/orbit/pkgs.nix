{ pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    inputs.devenv.outputs.packages.x86_64-linux.default

    # Nix stuff
    nix-index
    nix-tree
    comma
    rclone

    f2

    obs-studio

    # docker-buildx
    lazydocker

    vesktop

    # GUI
    qbittorrent

    bandwhich

    ripdrag
    pavucontrol
    seahorse
    gnome-software

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
