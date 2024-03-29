{
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) mkIf types mkOption mkDefault;
  cfg = config.hellebore.server.invoiceshelf;
  fpm = config.services.phpfpm.pools.invoiceshelf;
  webserver = config.services.nginx;
  package = pkgs.invoiceshelf.override {dataDir = cfg.dataDir;};
  domain = "${cfg.subdomain}.${config.networking.domain}";
in {
  options.hellebore.server.invoiceshelf =
    {
      dataDir = mkOption {
        default = "/var/lib/crater";
        description = lib.mdDoc "Directory to store Crater state/data files.";
        type = types.str;
      };

      user = mkOption {
        default = "invoiceshelf";
        type = types.nonEmptyStr;
        description = "Defines the user running InvoiceShelf.";
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
      group = "invoiceshelf";
      port = 0660;
    };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      inherit (cfg) group;
      isSystemUser = true;
    };

    users.groups.${cfg.group}.members = [cfg.user webserver.user];

    services.phpfpm.pools.invoiceshelf = {
      phpOptions = ''
        file_uploads = On
        upload_max_filesize = 64M
        post_max_size = 64M
      '';

      user = webserver.user;
      group = webserver.group;

      settings =
        {
          "listen.mode" = "${toString cfg.port}";
          "listen.owner" = webserver.user;
          "listen.group" = webserver.group;
        }
        // cfg.poolConfig;
    };

    hellebore.server.nginx.enable = mkDefault true;

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      enableACME = true;
      root = "/${package}/public";
      locations = {
        "/" = {
          priority = 1600;
          tryFiles = "$uri $uri/ /index.php?$query_string";
        };

        "~ \\.php$" = {
          priority = 500;
          extraConfig = ''
            fastcgi_pass unix:${fpm.socket};
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include ${webserver.package}/conf/fastcgi.conf;
          '';
        };

        "/favicon.ico" = {
          priority = 100;
          extraConfig = ''
            access_log off;
            log_not_found off;
          '';
        };

        "/robots.txt" = {
          priority = 100;
          extraConfig = ''
            access_log off;
            log_not_found off;
          '';
        };
      };

      extraConfig = ''
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag none;
        add_header Content-Security-Policy "frame-ancestors 'self'";
        index index.php;
        charset utf-8;
      '';
    };

    security.acme = {
      acceptTerms = true;
      certs = {
        ${domain}.email = cfg.acmeEmail;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}                            0775 ${webserver.user} ${webserver.group} - -"
      "f ${cfg.dataDir}/database.sqlite            0775 ${webserver.user} ${webserver.group} - -"
      "d ${cfg.dataDir}/public                     0775 ${webserver.user} ${webserver.group} - -"
      "d ${cfg.dataDir}/storage                    0775 ${webserver.user} ${webserver.group} - -"
      "d ${cfg.dataDir}/storage/app                0775 ${webserver.user} ${webserver.group} - -"
      "d ${cfg.dataDir}/storage/fonts              0775 ${webserver.user} ${webserver.group} - -"
      "d ${cfg.dataDir}/storage/framework          0775 ${webserver.user} ${webserver.group} - -"
      "d ${cfg.dataDir}/storage/framework/cache    0775 ${webserver.user} ${webserver.group} - -"
      "d ${cfg.dataDir}/storage/framework/sessions 0775 ${webserver.user} ${webserver.group} - -"
      "d ${cfg.dataDir}/storage/framework/views    0775 ${webserver.user} ${webserver.group} - -"
      "d ${cfg.dataDir}/storage/logs               0775 ${webserver.user} ${webserver.group} - -"
      "C ${cfg.dataDir}/.env                       0775 ${webserver.user} ${webserver.group} - ${package}/.env.example"
      "d ${cfg.dataDir}/bootstrap                  0775 ${webserver.user} ${webserver.group} - -"
      "d ${cfg.dataDir}/bootstrap/cache            0775 ${webserver.user} ${webserver.group} - -"
    ];
  };
}
