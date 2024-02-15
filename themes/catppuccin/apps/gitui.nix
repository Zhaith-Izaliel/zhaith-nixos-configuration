{
  pkgs,
  lib,
  inputs,
}: rec {
  package = pkgs.stdenvNoCC.mkDerivation {
    pname = "gitui-catppuccin";
    version = inputs.catppuccin-gitui.rev;

    src = inputs.catppuccin-gitui;

    installPhase = ''
      mkdir -p $out
      cp -r theme $out
    '';
  };
  file = "${package}/theme/macchiato.ron";
}
