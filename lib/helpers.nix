{ lib }:

{
  mkMergeTopLevel = attrs: (
    lib.attrsets.mapAttrs (k: v: lib.mkMerge v) (lib.attrsets.foldAttrs (n: a: [n] ++ a) [] attrs)
  );
}

