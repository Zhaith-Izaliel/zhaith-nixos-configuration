{ lib, config, ... }:

let
  inherit (lib) mkEnableOption mkOption mkMerge mkIf types;
  cfg = config.hellebore.games;
in
{
  options.hellebore.games = {
    dxvk = {
      enable = mkEnableOption "DXVK configuration management";

      config = mkOption {
        type = types.str;
        default = "";
        description = "DXVK configuration in CONF syntax.";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.dxvk.enable {
      home.file."dxvk.conf".text = cfg.dxvk.config;
    })
  ];
}

