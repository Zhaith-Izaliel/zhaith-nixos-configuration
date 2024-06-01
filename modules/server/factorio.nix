{
  config,
  options,
  lib,
  extra-types,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkIf mkDefault pipe;
  cfg = config.hellebore.server.factorio;
  domain = "${cfg.subdomain}.${config.networking.domain}";

  modList = pipe cfg.modsDir [
    builtins.readDir
    (lib.filterAttrs (k: v: v == "regular"))
    (lib.mapAttrsToList (k: v: k))
    (builtins.filter (lib.hasSuffix ".zip"))
  ];

  modToDrv = modFileName:
    pkgs.runCommand "copy-factorio-mods" {} ''
      mkdir $out
      cp ${cfg.modsDir + "/${modFileName}"} $out/${modFileName}
    ''
    // {deps = [];};
in {
  options.hellebore.server.factorio =
    {
      inherit (options.services.factorio) mods-dat admins extraSettingsFile token;
      modsDir = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          The directory containing the mods as .zip to install.
        '';
      };

      # mods-dat = mkOption {
      #   type = types.nullOr types.path;
      #   default = null;
      #   description = ''
      #     Mods settings can be changed by specifying a dat file, in the [mod
      #     settings file
      #     format](https://wiki.factorio.com/Mod_settings_file_format).
      #   '';
      # };

      # admins = mkOption {
      #   type = types.listOf types.str;
      #   default = [];
      #   example = ["username"];
      #   description = ''
      #     List of player names which will be admin.
      #   '';
      # };

      # extraSettingsFile = mkOption {
      #   type = types.nullOr types.path;
      #   default = null;
      #   description = ''
      #     File, which is dynamically applied to server-settings.json before
      #     startup.

      #     This option should be used for credentials.

      #     For example a settings file could contain:
      #     ```json
      #     {
      #       "game-password": "hunter1"
      #     }
      #     ```
      #   '';
      # };
    }
    // extra-types.server-app {
      name = "Factorio Server";
      package = "factorio-headless";
      port = 34197;
    };

  config = mkIf cfg.enable {
    services.factorio = {
      inherit (cfg) package port admins extraSettingsFile mods-dat;
      enable = true;
      openFirewall = true;
      mods =
        if cfg.modsDir == null
        then []
        else builtins.map modToDrv modList;
    };

    hellebore.server.nginx.enable = mkDefault true;
    services.nginx.streamConfig = ''
      server {
        listen 127.0.0.1:${toString cfg.port} udp reuseport;
        proxy_pass ${domain}:${toString cfg.port};
      }
    '';
  };
}
