{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkOption types mkIf cleanSource mkDefault;
  cfg = config.hellebore.server.calibre-web;
  domain = "${cfg.subdomain}.${config.networking.domain}";
in {
  options.hellebore.server.calibre-web =
    {
      library = mkOption {
        type = types.path;
        default = cleanSource /var/calibre/library;
        description = "";
      };
    }
    // extra-types.server-app {
      name = "Calibre Web";
      package = "calibre-web";
      port = 8083;
    };

  config = mkIf cfg.enable {
    services.calibre-web = {
      inherit (cfg) group package;
      enable = true;
      listen.port = cfg.port;
      options.calibreLibrary = cfg.library;
    };

    hellebore.server.nginx.enable = mkDefault true;
    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}";
      };
    };
  };
}
