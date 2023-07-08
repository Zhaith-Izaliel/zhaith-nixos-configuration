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
        sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
      } + "/Catppuccin-macchiato.tmTheme");
    };
    config = {
      theme = "catppuccin-macchiato";
    };
  };
}

