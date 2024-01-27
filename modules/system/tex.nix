{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hellebore.tex;
in {
  options.hellebore.tex = {
    enable = mkEnableOption "Hellebore LaTeX packages";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      texlive.combined.scheme-basic
      pandoc
    ];
  };
}
