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
  inputs.firefox-addons = {
    url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, ... }@inputs:
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
            hostname = "x1";
          };
          modules = [ ./hosts/x1 ];
        };
      };

      # Home configurations
      homeConfigurations = {
        orbit = lib.homeManagerConfiguration rec {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs outputs;
            system = "x86_64-linux";
          };
          modules = [ ./homes/orbit ];
        };
      };

      formatter = local-lib.forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.nixpkgs-fmt
      );

      packages = local-lib.forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          hello = pkgs.hello;
        }
      );

      devShells = local-lib.forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default =
            pkgs.mkShell {
              packages = with pkgs; [
                cargo
              ];
            };
        }
      );
    };
}
