{ config, lib, pkgs, ... }:


let
  builders = import ../../builders/default.nix { inherit pkgs; };
  inherit (lib) mkEnableOption mkIf;
  inherit (builders) nerd-font-patcher;
  cfg = config.hellebore.fonts;
in
{
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
        powerline-fonts
        cantarell-fonts
        ubuntu_font_family
        corefonts
        nerdfonts
        fira-code
        fira-code-symbols
        rictydiminished-with-firacode
        terminus_font
        font-awesome
        (nerd-font-patcher (cantarell-fonts.overrideAttrs {
          configurePhase = ''
            meson configure "-Dbuildvf=false -Dbuildstatics=true"
          '';
        }))
      ];

      fontconfig = {
        enable = true;
        antialias = true;
        includeUserConf = true;
        defaultFonts = {
          sansSerif = [ "Noto Sans" ];
          serif = [ "Noto Serif" ];
          monospace = [ "Noto Sans Mono" ];
          emoji = [ "Twitter Color Emoji" ];
        };
      };

      fontDir.enable = true;
    };
  };
}

