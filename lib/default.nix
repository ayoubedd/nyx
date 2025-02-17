{ lib, nixpkgs, ... }:
let
  mkHome = { specialArgs, modules ? [ ], }:
    lib.homeManagerConfiguration rec {
      pkgs = nixpkgs.legacyPackages.${specialArgs.system};
      extraSpecialArgs = specialArgs // {
        lo-pkgs = import ../packages { inherit pkgs; };
      };
      inherit modules;
    };

  systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];

in { inherit systems mkHome; }
