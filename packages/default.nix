{pkgs}: let
  nodejs-packages = import ../packages/nodejs {
    pkgs = pkgs;
    nodejs = pkgs.nodejs;
    stdenv = pkgs.stdenv;
  };
in {
  inherit nodejs-packages;
  kando = pkgs.callPackage ./kando.nix {};
  hyprland-patched = pkgs.callPackage ./hyprland-patched.nix {};
}
