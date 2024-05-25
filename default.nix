{ pkgs ? import <nixpkgs> }:
pkgs.stdenv.mkDerivation {
  name = "touchpadctl";
  src = ./src;

  buildInputs = with pkgs; [
    ghc
  ];

  buildPhase = ''
    ghc touchpadctl.hs -o touchpadctl
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp touchpadctl $out/bin
    cp symbols $out/bin
  '';
}
