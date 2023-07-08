{ pkgs, ... }:

{
  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      batdiff
    ];
    themes = {
       catppuccin-macchiato = builtins.readFile (pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat"; # Bat uses sublime syntax for its themes
        rev = "ba4d168";
        sha256 = "";
      } + "/Catppuccin-macchiato.tmTheme");
    };
    config = {
      theme = "catppuccin-macchiato";
    };
  };
}

