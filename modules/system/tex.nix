{
  config,
  lib,
  pkgs,
  stable-pkgs,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types mkPackageOption mkIf;
  cfg = config.hellebore.tex;
in {
  options.hellebore.tex = {
    enable = mkEnableOption "Hellebore LaTeX support";

    scheme = mkOption {
      type = types.enum [
        "minimal"
        "small"
        "basic"
        "medium"
        "tetex"
        "context"
        "gust"
        "full"
      ];
      default = "basic";
      description = "Defines the TexLive scheme to install. Not taken in account if you set `package`. See: https://nixos.wiki/wiki/TexLive";
    };

    package = mkPackageOption pkgs ["texlive" "combined" "scheme-${cfg.scheme}"] {
      extraDescription = "This option overrides the `scheme` option, if set.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      (with pkgs; [
        pandoc
        apostrophe
      ])
      ++ [
        cfg.package
      ];
  };
}
