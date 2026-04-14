{
  description = "My personal NixOS/User configuration";

  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.lanzaboote = {
    url = "github:nix-community/lanzaboote/v1.0.0";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.stylix = {
    url = "github:danth/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
    inputs.nur.follows = "nur";
  };
  inputs.nur = {
    url = "github:nix-community/NUR";
    inputs.flake-parts.follows = "flake-parts";
  };
  inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  inputs.vicinae.url = "github:vicinaehq/vicinae?ref=v0.20.12";
  inputs.nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://vicinae.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    { nixpkgs, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem =
        { pkgs, system, ... }:
        let
          pkgs' = import nixpkgs {
            inherit system;
            overlays = with inputs; [
              (final: prev: { vicinae = vicinae.packages.${system}.default; })
            ];
          };
        in
        {
          _module.args.pkgs = pkgs';
          formatter = pkgs'.treefmt;
          devShells.default = pkgs'.mkShell {
            packages = with pkgs'; [
              tombi
              stylua
              nixfmt
              just
              sops
              age
              just
              nixfmt
              disko
            ];
          };
        };

      flake = {
        nixosConfigurations = {
          x1 = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = with inputs; [
              nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
              sops-nix.nixosModules.sops
              disko.nixosModules.disko
              lanzaboote.nixosModules.lanzaboote
              home-manager.nixosModules.home-manager
              nur.modules.nixos.default
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
