{
  description = "Development environment for Touchpad Toggle helper";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          haskell-language-server
          ghc
          haskellPackages.fourmolu
        ];
        shellHook = "fish; exit";
      };

      packages.${system}.default = (import ./default.nix { inherit pkgs; });
    };
}
