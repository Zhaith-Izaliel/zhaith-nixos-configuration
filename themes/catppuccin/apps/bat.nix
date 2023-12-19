{ pkgs, lib, inputs }:

let
  package = pkgs.stdenv.mkDerivation rec {
    pname = "bat-catppuccin";
    version  = "ba4d168";

    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "bat";
      rev = version;
      sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
    };

    installPhase = ''
    mkdir -p $out
    cp -r *.tmTheme $out
    '';
  };
in
{
  inherit package;
  inherit (package) src;
  name = "catppuccin-macchiato";
  file = "Catppuccin-macchiato.tmTheme";
}

