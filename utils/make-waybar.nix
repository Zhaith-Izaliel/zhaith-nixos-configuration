{ lib }:

let
  inherit (lib) intersectLists;
in
{
  mkWaybarModules = modules: modulesPosition: {
    modules-left = intersectLists modules modulesPosition.modules-left;
    modules-center = intersectLists modules modulesPosition.modules-center;
    modules-right = intersectLists modules modulesPosition.modules-right;
  };
}

