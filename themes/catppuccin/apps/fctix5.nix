{ pkgs, inputs, colors }:

{
  package = pkgs.stdenv.mkDerivation {
    pname = "catppuccin-fcitx5";
    version = inputs.catppuccin-fcitx5.rev;
    src = inputs.catppuccin-fcitx5;

    installPhase = ''
    local themeDir=$out/share/fcitx5/themes
    mkdir -p $themeDir
    cp -aR ./src/* $themeDir
    '';
  };
  name = "catppuccin-macchiato";
  extraConfig = ''
    # Tray Label Outline Color
    TrayOutlineColor=${colors.mantle}

    # Tray Label Text Color
    TrayTextColor=${colors.text}
  '';
}

