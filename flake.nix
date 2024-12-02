{
  description = "My personal NixOS/User configuration";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.orbit-nvim.url = "github:ayoubedd/nvim";
  inputs.nur.url = "github:nix-community/NUR";
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
    inputs.home-manager.follows = "home-manager";
  };
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs = { self, ... }@inputs:
    let
      inherit (inputs)
        nixpkgs nixos-hardware flake-parts nur stylix home-manager;
      lib = nixpkgs.lib // home-manager.lib // {
        lo = (import ./lib { inherit lib nixpkgs; });
      };
    in flake-parts.lib.mkFlake { inherit inputs; } {
      systems = lib.lo.systems;
      perSystem = { config, inputs', pkgs, system, ... }: {
        formatter = pkgs.nixpkgs-fmt;
      };
      flake = {
        nixosConfigurations = {
          x1 = lib.nixosSystem {
            specialArgs = { inherit inputs nixos-hardware; };
            modules = [ ./hosts/x1 ];
          };
          kraken = lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [ ./hosts/kraken ];
          };
        };

        homeConfigurations = {
          "orbit@x1" = lib.lo.mkHome {
            specialArgs = {
              inherit inputs;
              system = "x86_64-linux";
              host = "x1";
            };
            modules = [ ./homes/orbit ];
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
