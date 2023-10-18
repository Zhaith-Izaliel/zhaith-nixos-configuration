{ lib, runCommand, nixosOptionsDoc, ...}:

let
  modules = import ./default.nix {};

  # Evaluate modules
  eval = lib.evalModules {
    modules = [
      modules.system
      modules.home-manager
    ];

    check = false;
  };

  # Generate docs
  optionsDoc = nixosOptionsDoc {
    inherit (eval) options;
  };
in

# create a derivation for capturing the markdown output
runCommand "options-doc.md" {} ''
  cat ${optionsDoc.optionsCommonMark} >> $out
''

