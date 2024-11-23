{inputs}: final: prev: let
  inherit (final.stdenv.hostPlatform) system;
  packages = import ../packages {
    inherit inputs;
    pkgs = final;
  };
in
  packages
  // {
    compose2nix = inputs.compose2nix.packages.${system}.default;
    wezterm = inputs.wezterm.packages.${system}.default;
    umu = inputs.umu.packages.${system}.umu;
  }
