{
  inputs,
  bat,
  pkgs,
}: let
  extraThemeProperties = ''
    [manager]

    syntect_theme="${bat.src}/${bat.file}"
  '';
in rec {
  package = pkgs.stdenv.mkDerivation {
    pname = "catppuccin-yazi";
    version = inputs.catppuccin-yazi.shortRev;

    src = inputs.catppuccin-yazi;

    buildInputs = with pkgs; [
      fusion
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp themes/macchiato.toml $out
      runHook postInstall
    '';

    postInstallPhase = ''
      fusion toml themes/macchiato.toml ${extraThemeProperties} -o $out/macchiato.toml
    '';
  };
  file = "${package}/macchiato.toml";
}
