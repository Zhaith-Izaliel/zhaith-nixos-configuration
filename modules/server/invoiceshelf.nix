{
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) mkIf types mkOption;
  cfg = config.services.invoiceshelf;
  fpm = config.services.phpfpm.pools.invoiceshelf;
  package = pkgs.invoiceshelf.override {dataDir = cfg.dataDir;};
  domain = "${cfg.subdomain}.${config.networking.domain}";
in {
  options.services.crater =
    {
      dataDir = mkOption {
        default = "/var/lib/crater";
        description = lib.mdDoc "Directory to store Crater state/data files.";
        type = types.str;
      };

      poolConfig = mkOption {
        type = with types; attrsOf (oneOf [str int bool]);
        default = {
          "pm" = "dynamic";
          "pm.max_children" = 32;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 4;
          "pm.max_requests" = 500;
        };
        description = lib.mdDoc ''
          Options for the crater PHP pool. See the documentation on <literal>php-fpm.conf</literal>
          for details on configuration directives.
        '';
      };
    }
    // extra-types.server-app {
      inherit package;
      name = "InvoiceShelf";
      port = 0660;
    };

  config = mkIf cfg.enable {
    services.phpfpm.pools.invoiceshelf = {
      phpOptions = ''
        file_uploads = On
        upload_max_filesize = 64M
        post_max_size = 64M
      '';

      user = cfg.user;
      group = cfg.group;

      settings =
        {
          "listen.mode" = "${toString cfg.port}";
          "listen.owner" = cfg.user;
          "listen.group" = cfg.group;
        }
        // cfg.poolConfig;
    };

    hellebore.server.nginx.enable = true;

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      root = "/${package}/public";
      locations = {
        "/".tryFiles = "$uri $uri/ =404";

        "~ \\.php$".extraConfig = ''
          php_fastcgi unix/${fpm.socket};
        '';
      };
    };

    security.acme = {
      acceptTerms = true;
      certs = {
        ${domain}.email = cfg.acmeEmail;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}                            0711 ${cfg.user} ${cfg.group} - -"
      "f ${cfg.dataDir}/database.sqlite            0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/public                     0755 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage                    0711 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/app                0711 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/fonts              0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/framework          0775 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/framework/cache    0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/framework/sessions 0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/framework/views    0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/logs               0775 ${cfg.user} ${cfg.group} - -"
      "C ${cfg.dataDir}/.env                       0700 ${cfg.user} ${cfg.group} - ${package}/.env.example"
      "d ${cfg.dataDir}/bootstrap                  0711 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/bootstrap/cache            0775 ${cfg.user} ${cfg.group} - -"
    ];
  };
}
