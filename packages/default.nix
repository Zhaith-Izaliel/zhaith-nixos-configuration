{pkgs}: {
  kando = pkgs.callPackage ./kando.nix {};
  fusion = pkgs.callPackage ./fusion.nix {};
  affine = pkgs.callPackage ./affine.nix {};
  modrinth = pkgs.callPackage ./modrinth.nix {};
}
