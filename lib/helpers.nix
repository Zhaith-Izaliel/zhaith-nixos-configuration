{ lib }:

{
  mkMergeTopLevel = attrs: (
    lib.attrset.mapAttrs (k: v: lib.mkMerge v) (lib.attrset.foldAttrs (n: a: [n] ++ a) [] attrs)
  );
}

