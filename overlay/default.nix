{inputs}: final: prev: let
  packages = import ../packages {pkgs = final;};
in
  packages
