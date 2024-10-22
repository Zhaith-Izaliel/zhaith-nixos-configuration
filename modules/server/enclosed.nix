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

      secretEnvFile = mkOption {
        default = "";
        type = types.path;
        description = ''
          The env file containing the DB password, in the form:
          ```
          # Generated with
          # `authelia crypto hash generate argon2 --random --random.length 64 --random.charset alphanumeric`
            AUTHENTICATION_JWT_SECRET="token"
          ```
        '';
      };
    }
    // extra-types.server-app {
      inherit domain;
      name = "Enclosed";
      port = 8787;
    };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      enclosed = {
        image = "corentinth/enclosed";

        volumes = [
          "${cfg.volume}:/app/.data"
        ];

        environmentFiles = [
          cfg.secretEnvFile
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
