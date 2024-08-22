{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkOption types mkIf mkDefault;
  cfg = config.hellebore.server.homepage;
  domain = config.networking.domain;
in {
  options.hellebore.server.homepage =
    {
      secretsEnvFile = mkOption {
        type = types.path;
        default = "";
        description = ''
          A file containing environment variables with secrets for Homepage Dashboard.
          This file should be encrypted with agenix.

          Every environment secrets should start with `HOMEPAGE_VAR_` or `HOMEPAGE_FILE_`
          See https://gethomepage.dev/latest/installation/docker/#using-environment-secrets
        '';
      };

      settings = {
        theme = mkOption {
          default = "dark";
          type = types.enum ["dark" "light"];
          description = "Defines Homepage's theme.";
        };

        colorPalette = mkOption {
          default = "slate";
          type = types.enum [
            "slate"
            "gray"
            "zinc"
            "neutral"
            "stone"
            "amber"
            "yellow"
            "lime"
            "green"
            "emerald"
            "teal"
            "cyan"
            "sky"
            "blue"
            "indigo"
            "violet"
            "purple"
            "fuchsia"
            "pink"
            "rose"
            "red"
            "white"
          ];
          description = "Defines Homepage's color palette";
        };
      };
    }
    // extra-types.server-app {
      name = "Homepage Dashboard";
      package = "homepage-dashboard";
      group = "homepage";
      user = "homepage";
      port = 8082;
    };

  config = mkIf cfg.enable {
    services.homepage-dashboard = {
      inherit (cfg) package;
      enable = true;
      listenPort = cfg.port;

      settings = {
        inherit (cfg.settings) theme;
        color = cfg.settings.colorPalette;
      };
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