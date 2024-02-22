{
  inputs,
  pkgs,
  ...
}: let
  virgilribeyre-package = inputs.virgilribeyre-com.packages.${pkgs.system}.default;
in {
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "jellyfin.ethereal-edelweiss.cloud" = {
        # Jellyfin
        enableACME = true;
        forceSSL = true;

        locations = {
          "/" = {
            proxyPass = "http://localhost:8096";
          };
          "/socket" = {
            proxyPass = "http://localhost:8096";
            proxyWebsockets = true;
          };
        };
      };

      "books.ethereal-edelweiss.cloud" = {
        # Jellyfin
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://localhost:8083";
        };
      };

      "nextcloud.ethereal-edelweiss.cloud" = {
        # Nextcloud
        enableACME = true;
        forceSSL = true;
      };

      "virgilribeyre.com" = {
        enableACME = true;
        forceSSL = true;

        serverAliases = [
          "virgilribeyre.com"
          "www.virgilribeyre.com"
        ];

        locations = {
          "/" = {
            root = "${virgilribeyre-package}";
            index = "index.html";
          };

          tryFiles = "$uri $uri/ /index.html";
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      "nextcloud.ethereal-edelweiss.cloud".email = "virgil.ribeyre@protonmail.com";
      "jellyfin.ethereal-edelweiss.cloud".email = "virgil.ribeyre@protonmail.com";
      "books.ethereal-edelweiss.cloud".email = "virgil.ribeyre@protonmail.com";
      "virgilribeyre.com".email = "virgil.ribeyre@protonmail.com";
    };
  };
}
