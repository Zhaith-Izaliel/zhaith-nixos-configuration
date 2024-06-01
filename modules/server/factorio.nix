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
    }
    // extra-types.server-app {
      name = "Factorio Server";
      package = "factorio-headless";
      port = 34197;
    };

  config = mkIf cfg.enable {
    services.factorio = {
      inherit (cfg) package admins extraSettingsFile mods-dat port;
      enable = true;
      openFirewall = true;
      requireUserVerification = false;
      mods =
        if cfg.modsDir == null
        then []
        else builtins.map modToDrv modList;
    };
  };
}
