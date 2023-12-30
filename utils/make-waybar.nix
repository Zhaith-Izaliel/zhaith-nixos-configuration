{ lib }:

let
  inherit (lib) intersectLists;
in
{
  mkWaybarModules = { modules, modulesPosition }: {
    left-modules = intersectLists modules modulesPosition.left-modules;
    center-modules = intersectLists modules modulesPosition.center-modules;
    right-modules = intersectLists modules modulesPosition.right-modules;
  };
}

