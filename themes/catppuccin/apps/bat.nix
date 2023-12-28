{ pkgs, lib, inputs }:

let
  package = pkgs.stdenv.mkDerivation {
    pname = "bat-catppuccin";
    version  = inputs.catppuccin-bat.rev;

    src = inputs.catppuccin-bat;

    installPhase = ''
    mkdir -p $out
    cp -r *.tmTheme $out
    '';
  };
in
{
  inherit package;
  inherit (package) src;
  name = "catppuccin-macchiato";
  file = "Catppuccin-macchiato.tmTheme";
}

