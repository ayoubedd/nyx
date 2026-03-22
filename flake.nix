{
  description = "My personal NixOS/User configuration";

  inputs.devenv-root = {
    url = "file+file:///dev/null";
    flake = false;
  };
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.nur = {
    url = "github:nix-community/NUR";
    inputs.flake-parts.follows = "flake-parts";
  };
  inputs.devenv = {
    url = "github:cachix/devenv?ref=latest";
    inputs.nixpkgs.follows = "nixpkgs";
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
  inputs.eilmeldung.url = "github:christo-auer/eilmeldung";
  inputs.eilmeldung.inputs.nixpkgs.follows = "nixpkgs";

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
    { devenv-root, ... }@inputs:
    let
      inherit (inputs) flake-parts nixpkgs home-manager;
      devenv-root' =
        let
          devenvRootFileContent = builtins.readFile devenv-root.outPath;
        in
        nixpkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = with inputs; [
        devenv.flakeModule
        home-manager.flakeModules.home-manager
      ];
      systems = [ "x86_64-linux" ];
      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.treefmt;
          devenv.shells.default = {
            devenv.root = devenv-root';
            imports = [ ./devenv.nix ];
          };
        };

      flake = {
        nixosConfigurations = {
          x1 = nixpkgs.lib.nixosSystem {
            modules = with inputs; [
              nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
              sops-nix.nixosModules.sops
              disko.nixosModules.disko
              ./machines/x1
            ];
          };
          kraken = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [ ./machines/kraken ];
          };
        };

        homeConfigurations = {
          "orbit@x1" = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              overlays = with inputs; [
                vicinae.overlays.default
                devenv.overlays.default
                eilmeldung.overlays.default
              ];
            };
            extraSpecialArgs.host = "x1";
            modules = with inputs; [
              vicinae.homeManagerModules.default
              stylix.homeModules.stylix
              nur.modules.homeManager.default
              nix-flatpak.homeManagerModules.nix-flatpak
              eilmeldung.homeManager.default
              ./homes/orbit
            ];
          };
        };
      };
    };
}
