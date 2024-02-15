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
        corefonts
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
        localConf = ''
          <match target="pattern">
            <test name="prgname" compare="eq">
              <string>kitty</string>
            </test>
            <edit name="family" mode="prepend" binding="strong">
              <string>FiraCode Nerd Font</string>
            <family>Ricty Diminished with Fira Code</family>
            <family>Noto Color Emoji</family>
            </edit>
          </match>
          <alias>
           <family>FiraCode Nerd Font</family>
           <prefer>
            <family>FiraCode Nerd Font</family>
            <family>Ricty Diminished with Fira Code</family>
            <family>Noto Color Emoji</family>
            <family/>
           </prefer>
          </alias>
        '';
      };

      fontDir.enable = true;
    };
  };
}
