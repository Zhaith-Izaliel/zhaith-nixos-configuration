{inputs}: final: prev: let
  inherit (packages) nodejs-packages;
  packages = import ../packages {pkgs = final;};
in {
  inherit (nodejs-packages) commitlint-format-json;

  commitlint = nodejs-packages."@commitlint/cli".overrideAttrs (
    final: prev: {
      buildInputs = [nodejs-packages.commitlint-format-json] ++ prev.buildInputs;
      installPhase =
        prev.installPhase
        + ''

          mkdir -p $out/node_modules
          ln -s ${nodejs-packages.commitlint-format-json}/lib/node_modules/* $out/node_modules
        '';
    }
  );

  commitlint-config-conventional =
    nodejs-packages."@commitlint/config-conventional";
}
