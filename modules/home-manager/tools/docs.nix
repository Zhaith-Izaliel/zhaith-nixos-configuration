{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.hellebore.tools.docs;
in
{
  options.hellebore.tools.docs = {
    enable = mkEnableOption "Hellebore's documentation helpers";
  };

  config = mkIf cfg.enable {
    programs.tealdeer = {
      enable = true;
      settings = {
        display = {
          compact = false;
          use_pager = true;
        };
        updates = {
          auto_update = true;
          auto_update_interval_hours = 24;
        };
      };
    };
  };
}

