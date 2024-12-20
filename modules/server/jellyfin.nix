{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkIf mkDefault;
  cfg = config.hellebore.server.jellyfin;
  domain = "${cfg.subdomain}.${config.networking.domain}";
in {
  options.hellebore.server.jellyfin = extra-types.server-app {
    inherit domain;
    name = "Jellyfin";
    package = "jellyfin";
    port = 8096;
  };

  config = mkIf cfg.enable {
    services.jellyfin = {
      inherit (cfg) group;
      enable = true;
    };

    hellebore.server.nginx.enable = mkDefault true;

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;

      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString cfg.port}";
        };

        "/socket" = {
          proxyPass = "http://localhost:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
