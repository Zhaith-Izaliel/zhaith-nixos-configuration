{
  inputs,
  bat,
  pkgs,
}: let
  extraThemeProperties = pkgs.writeTextFile {
    name = "yazi-highlight-theme-location.toml";
    text = ''
      [manager]
      syntect_theme="${bat.src}/${bat.file}"
    '';
  };
in rec {
  package = pkgs.stdenv.mkDerivation {
    pname = "catppuccin-yazi";
    version = inputs.catppuccin-yazi.shortRev;

    src = inputs.catppuccin-yazi;

    buildInputs = with pkgs; [
      fusion
    ];

    installPhase = ''
      mkdir -p $out
      fusion toml themes/macchiato.toml ${extraThemeProperties} -o $out/macchiato.toml
    '';
  };
  file = "${package}/macchiato.toml";
}
