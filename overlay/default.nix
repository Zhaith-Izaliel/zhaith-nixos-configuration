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

  commitlint = nodejs-packages."@commitlint/cli".overrideAttrs (final:
    prev: {
      buildInputs = [ nodejs-packages.commitlint-format-json ] ++ prev.buildInputs;
      installPhase = prev.installPhase + ''

      mkdir -p $out/node_modules
      ln -s ${nodejs-packages.commitlint-format-json}/lib/node_modules/* $out/node_modules
      '';
    }
  );

  commitlint-config-conventional =
    nodejs-packages."@commitlint/config-conventional";
} // scripts

