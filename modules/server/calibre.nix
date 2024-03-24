{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkOption types mkIf cleanSource;
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
      inherit (cfg) group port package;
      enable = true;
      options.calibreLibrary = cfg.library;
    };

    hellebore.server.nginx.enable = true;
    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}";
      };
    };

    security.acme = {
      acceptTerms = true;
      certs = {
        ${domain}.email = cfg.acmeEmail;
      };
    };
  };
}
