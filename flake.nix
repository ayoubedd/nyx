{
  description = "My personal NixOS/User configuration";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nur.follows = "nur";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    eilmeldung = {
      url = "github:christo-auer/eilmeldung";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # impermanence = {
    #   url = "github:nix-community/impermanence";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.home-manager.follows = "home-manager";
    # };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

  };

  nixConfig = {
    extra-substituters = [
      "https://cache.xinux.uz"
      "https://attic.xuyh0120.win/lantian"
    ];
    extra-trusted-public-keys = [
      "cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };

  outputs =
    { nixpkgs, flake-parts, ... }@inputs:
    let
      overlay = overlays: { nixpkgs.overlays = overlays; };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.treefmt;
        };

      flake = {
        nixosConfigurations = {
          x1 = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = with inputs; [
              (overlay [ inputs.eilmeldung.overlays.default ])
              (overlay [ inputs.nix-cachyos-kernel.overlays.pinned ])
              nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
              sops-nix.nixosModules.sops
              disko.nixosModules.disko
              lanzaboote.nixosModules.lanzaboote
              home-manager.nixosModules.home-manager
              nur.modules.nixos.default
              ./modules/nixos
              ./machines/x1
            ];
          };
          isos = {
            rescubox = nixpkgs.lib.nixosSystem {
              modules = [
                "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix"
                ./misc/nixos/iso/rescubox
              ];
            };
          };
        };
      };
    };
}
