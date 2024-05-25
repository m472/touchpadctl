{ pkgs ? import <nixpkgs> }:
pkgs.stdenv.mkDerifation {
  name = "touchpadctrl";
  src = "src";

  buildPhase = ''
    ghc touchpadctl.hs -o touchpadctl
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp $src/touchpadctrl $out/bin
  '';
}
