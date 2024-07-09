{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkOption types mkIf mkDefault;
  cfg = config.hellebore.server.radicale;
  domain = "${cfg.subdomain}.${config.networking.domain}";
in {
  options.hellebore.server.radicale =
    {
      storage = mkOption {
        type = types.path;
        default = /var/radicale/storage;
        description = "The storage location for Radicale.";
      };

      auth = {
        file = mkOption {
          type = types.path;
          default = "";
          description = ''
            The file containing the authentication for every users. Must be encrypted by default, either by htpasswd or with agenix.
          '';
        };

        encryption = mkOption {
          default = "bcrypt";
          type = types.enum ["plain" "bcrypt" "md5"];
          description = ''
            The encryption scheme of the auth file. If you choose "plain" you must encrypt it on the NixOS side with agenix.
          '';
        };
      };
    }
    // extra-types.server-app {
      name = "Radicale";
      package = "radicale";
      group = "radicale";
      user = "radicale";
      port = 5232;
    };

  config = mkIf cfg.enable {
    services.radicale = {
      inherit (cfg) package;
      enable = true;

      settings = {
        server = {
          hosts = ["localhost:${toString cfg.port}"];
        };

        auth = {
          type = "htpasswd";
          htpasswd_filename = cfg.auth.file;
          htpasswd_encryption = cfg.auth.encryption;
        };

        storage = {
          filesystem_folder = cfg.storage;
        };
      };
    };

    hellebore.server.nginx.enable = mkDefault true;

    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
        extraConfig = ''
          proxy_pass_header Authorization;
          proxy_set_header  X-Script-Name /;
        '';
      };
    };
  };
}
