{
  description = "My personal NixOS/User configuration";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };


  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
    in
    {

      # Hosts configurations
      nixosConfigurations = {
        # Personal laptop
        x1 = lib.nixosSystem {
          specialArgs = {
            inherit inputs;
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
          modules = [
            ./homes/orbit
          ];
        };
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
