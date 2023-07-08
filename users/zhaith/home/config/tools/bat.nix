{ pkgs, theme, ... }:

{
  programs.bat = {
    enable = true;

    inherit (theme.bat-theme.bat) themes;

    extraPackages = with pkgs.bat-extras; [
      batdiff
    ];

    config = {
      theme = "catppuccin-macchiato";
    };
  };
}

