{ final, prev }:
let
  scripts = import ../assets/scripts { pkgs = prev; };
in
{
  tape = import ../assets/packages/tape { pkgs = prev; };
  greetd.greetd = prev.callPackage ../assets/packages/greetd {};
} // scripts

