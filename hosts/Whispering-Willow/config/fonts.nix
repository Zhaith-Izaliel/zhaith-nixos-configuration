{ config, pkgs, unstable-pkgs, ... }:

{
  # Fonts
  fonts = {
    fonts = with pkgs; [
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
}

