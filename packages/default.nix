{pkgs}: {
  kando = pkgs.callPackage ./kando.nix {};
  fusion = pkgs.callPackage ./fusion.nix {};
}
