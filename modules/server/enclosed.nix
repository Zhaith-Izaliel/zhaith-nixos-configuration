{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkIf types mkOption mkDefault;
  cfg = config.hellebore.server.enclosed;
  domain = "${cfg.subdomain}.${config.networking.domain}";
in {
  options.hellebore.server.enclosed =
    {
      volume = mkOption {
        default = "/var/lib/enclosed";
        description = lib.mdDoc "Directory to store Invoiceshelf volume.";
        type = types.nonEmptyStr;
      };
    }
    // extra-types.server-app {
      inherit domain;
      name = "Enclosed";
      port = 8787;
    };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      invoiceshelf = {
        image = "corentinth/enclosed";

        volumes = [
          "${cfg.volume}:/app/.data"
        ];

        ports = [
          "${toString cfg.port}:8787"
        ];
      };
    };

    hellebore.server.nginx.enable = mkDefault true;

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString cfg.port}";
        };
      };
    };
  };
}
