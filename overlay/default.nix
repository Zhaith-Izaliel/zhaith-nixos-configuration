{ final, prev }:
let
  nodejs-packages = import ../assets/packages/nodejs {
    pkgs = prev;
    nodejs = prev.nodejs;
    stdenv = prev.stdenv;
  };
  scripts = import ../assets/scripts { pkgs = prev; };
in
{
  inherit (nodejs-packages) commitlint-format-json;

  tape = import ../assets/packages/tape { pkgs = prev; };

  commitlint = nodejs-packages."@commitlint/cli";

  commitlint-config-conventional =
    nodejs-packages."@commitlint/config-conventional";
} // scripts

