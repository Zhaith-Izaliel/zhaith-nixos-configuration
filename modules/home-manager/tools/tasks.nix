{ config, lib, ... }:

with lib;

let
  cfg = config.hellebore.tools.tasks;
in
{
  options.hellebore.tools.tasks = {
    enable = mkEnableOption "Hellebore's tasks management";
  };

  config = mkIf cfg.enable {
    programs.taskwarrior = {
      enable = true;
    };
  };
}

