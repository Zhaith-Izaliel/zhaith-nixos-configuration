{ lib }:

let
  inherit (lib) intersectLists;
  inherit (builtins) match mapAttrs removeAttrs;
in
{
  mkWaybarModules = modules: modulesPosition:
  let
    processedGroupModules = removeAttrs (mapAttrs (name: value:
      if (match "group/.*" name) != null then
        { modules = intersectLists value modulesPosition.${name}.modules; }
      else
        value
      )
    modules) [ "modules" ];
  in
  {
    modules-left = intersectLists modules.modules modulesPosition.modules-left;
    modules-center = intersectLists modules.modules modulesPosition.modules-center;
    modules-right = intersectLists modules.modules modulesPosition.modules-right;
  } // processedGroupModules;
}

