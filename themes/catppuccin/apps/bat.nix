{
  pkgs,
  lib,
  inputs,
}: let
  package = pkgs.stdenvNoCC.mkDerivation {
    pname = "catppuccin-bat";
    version = inputs.catppuccin-bat.rev;

    src = inputs.catppuccin-bat;

    installPhase = ''
      mkdir -p "$out"
      cp -r themes/* "$out"
    '';
  };
in {
  inherit package;
  src = "${package}";
  name = "Catppuccin Macchiato";
  file = "Catppuccin Macchiato.tmTheme";
}
