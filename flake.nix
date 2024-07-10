{
  description = "My personal NixOS/User configuration";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.nur.url = "github:nix-community/NUR";

  outputs = { self, nur, ... }@inputs:
    let
      inherit (self) outputs;
      inherit (inputs) nixpkgs home-manager nixos-hardware flake-utils;
      lib = nixpkgs.lib // home-manager.lib;
      local-lib = import ./lib { inherit flake-utils; };
    in
    {
      # Hosts configurations
      nixosConfigurations = {
        # Personal laptop
        x1 = lib.nixosSystem {
          specialArgs = {
            inherit inputs nixos-hardware;
          };
          modules = [ ./hosts/x1 ];
        };

        kraken = lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./hosts/kraken ];
        };
      };

      # Home configurations
      homeConfigurations = {
        "orbit@x1" = lib.homeManagerConfiguration rec {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs =
            let
              my-pkgs = import ./packages { inherit pkgs; };
            in
            {
              inherit inputs outputs my-pkgs;
              system = "x86_64-linux";
              host = "x1";
            };
          modules = [
            ./homes/orbit
            nur.hmModules.nur
          ];
        };

        "orbit@kraken" = lib.homeManagerConfiguration rec {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs =
            let
              my-pkgs = import ./packages { inherit pkgs; };
            in
            {
              inherit inputs outputs my-pkgs;
              system = "x86_64-linux";
              host = "kraken";
            };
          modules = [
            ./homes/orbit
            nur.hmModules.nur
          ];
        };
      };

      formatter = local-lib.forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.nixpkgs-fmt
      );
    };
}
