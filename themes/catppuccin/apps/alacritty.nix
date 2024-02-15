{
  inputs,
  pkgs,
}: rec {
  package = pkgs.stdenvNoCC.mkDerivation {
    pname = "catppuccin-alacritty";
    version = inputs.catppuccin-alacritty.shortRev;
    src = inputs.catppuccin-alacritty;

    installPhase = ''
      mkdir -p $out
      cp -r *.toml $out
    '';
  };

  file = "${package}/catppuccin-macchiato.toml";
}
