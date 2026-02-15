{
  description = "My personal NixOS/User configuration";

  inputs.devenv-root = {
    url = "file+file:///dev/null";
    flake = false;
  };
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.nur = {
    url = "github:nix-community/NUR";
    inputs.flake-parts.follows = "flake-parts";
  };
  inputs.devenv = {
    url = "github:cachix/devenv?ref=latest";
  };
  inputs.nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

  inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.stylix = {
    url = "github:danth/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
    inputs.nur.follows = "nur";
  };

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  inputs.vicinae.url = "github:vicinaehq/vicinae";

  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://vicinae.cachix.org"
      "https://devenv.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    { self, devenv-root, ... }@inputs:
    let
      inherit (inputs)
        nixpkgs
        nixos-hardware
        flake-parts
        nur
        stylix
        home-manager
        ;
      lib =
        nixpkgs.lib
        // home-manager.lib
        // {
          lo = (import ./lib { inherit lib nixpkgs; });
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devenv.flakeModule ];
      systems = lib.lo.systems;
      perSystem =
        {
          config,
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          formatter = pkgs.treefmt;
          devenv.shells.default = {
            process.managers.process-compose.configFile = ./.;
            devenv.root =
              let
                devenvRootFileContent = builtins.readFile devenv-root.outPath;
              in
              pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;
            imports = [ ./devenv.nix ];
          };
        };
      flake = {
        nixosConfigurations = {
          x1 = lib.nixosSystem {
            specialArgs = { inherit inputs nixos-hardware; };
            modules = [ ./machines/x1 ];
          };
          kraken = lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [ ./machines/kraken ];
          };
        };

        homeConfigurations = {
          "orbit@x1" = lib.lo.mkHome {
            specialArgs = {
              inherit inputs;
              system = "x86_64-linux";
              host = "x1";
            };
            modules = [
              ./homes/orbit
              inputs.vicinae.homeManagerModules.default
            ];
          };
          "orbit@kraken" = lib.lo.mkHome {
            specialArgs = {
              inherit inputs;
              system = "x86_64-linux";
              host = "kraken";
            };
            modules = [ ./homes/orbit ];
          };
        };
      };
    };
}
