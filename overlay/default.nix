{inputs}: final: prev: let
  packages = import ../packages {pkgs = final;};
in
  packages
  // {
    compose2nix = inputs.compose2nix.packages.x86_64-linux.default;
  }
