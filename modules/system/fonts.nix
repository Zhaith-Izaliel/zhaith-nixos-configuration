{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.fonts;
in {
  options.hellebore.fonts = {
    enable = mkEnableOption "Hellebore fonts configuration";
  };

  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-emoji
        noto-fonts-cjk-sans
        twitter-color-emoji
        cantarell-fonts
        ubuntu_font_family
        lmodern
        # corefonts
        (nerdfonts.override {
          fonts = [
            "Ubuntu"
            "UbuntuMono"
            "FiraMono"
            "FiraCode"
            "Noto"
            "Terminus"
          ];
        })
        fira-code
        fira-code-symbols
        rictydiminished-with-firacode
        terminus_font
      ];

      fontconfig = {
        enable = true;
        antialias = true;
        includeUserConf = true;
        defaultFonts = {
          sansSerif = ["Noto Sans"];
          serif = ["Noto Serif"];
          monospace = ["FiraCode Nerd Font"];
          emoji = ["Twitter Color Emoji"];
        };
      };

      fontDir.enable = true;
    };
  };
}
