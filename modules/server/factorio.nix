{
  config,
  options,
  lib,
  extra-types,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkIf pipe;
  cfg = config.hellebore.server.factorio;

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
      inherit (options.services.factorio) mods-dat admins extraSettingsFile requireUserVerification game-name;
      modsDir = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          The directory containing the mods as .zip to install.
        '';
      };

      autosave-interval =
        options.services.factorio.autosave-interval
        // {
          default = 20;
        };
    }
    // extra-types.server-app {
      name = "Factorio Server";
      package = "factorio-headless";
      port = 34197;
    };

  config = mkIf cfg.enable {
    services.factorio = {
      inherit (cfg) package admins extraSettingsFile mods-dat port autosave-interval requireUserVerification game-name;
      enable = true;
      openFirewall = true;
      loadLatestSave = true;
      mods =
        if cfg.modsDir == null
        then []
        else builtins.map modToDrv modList;
    };

    services.fail2ban.jails = {
      factorio = {
        filter = {
          INCLUDES.before = "common.conf";

          Definition = {
            journalmatch = "_SYSTEMD_UNIT=factorio.service";
            failregex = ''^.*Refusing connection for address \(IP ADDR:\(\{<HOST>.* PasswordMismatch.*$'';
            ignoreregex = "";
          };
        };

        settings = {
          port = "${toString cfg.port}";
          banaction = "%(banaction_allports)s";
          backend = "systemd";
          filter = "factorio";
          maxretry = 3;
          bantime = 14400;
          findtime = 14400;
        };
      };
    };
  };
}
