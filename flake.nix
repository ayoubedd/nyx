{
  description = "My personal NixOS/User configuration";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, flake-utils, ... }@inputs:
    let
      inherit (self) outputs;
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
            hostname = "x1";
          };
          modules = [ ./hosts/x1 ];
        };
      };

      # Home configurations
      homeConfigurations = {
        orbit = lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./homes/orbit ];
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
