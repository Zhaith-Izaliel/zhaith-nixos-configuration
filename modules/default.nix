{
  extraHomeManagerModules ? [],
  extraSystemModules ? [],
  extraServerModules ? [],
}: {
  system = {...}: {imports = [./system] ++ extraSystemModules;};
  home-manager = {...}: {imports = [./home-manager] ++ extraHomeManagerModules;};
  server = {...}: {imports = [./server] ++ extraServerModules;};
}
