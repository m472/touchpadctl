{ pkgs ? import <nixpkgs> }:
pkgs.stdenv.mkDerivation {
  name = "touchpadctl";
  src = ./src;

  buildInputs = with pkgs; [
    ghc
  ];

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  buildPhase = ''
    ghc touchpadctl.hs -o touchpadctl
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp touchpadctl $out/bin
  '';

  postFixup = ''
    wrapProgram $out/bin/touchpadctl \
      --set PATH ${pkgs.lib.makeBinPath (with pkgs; [
        libnotify
        hyprland
      ])}
  '';
}
