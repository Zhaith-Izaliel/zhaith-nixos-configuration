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
        addSSL = true;
        enableACME = true;
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
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:8083";
        };
      };

      "nextcloud.ethereal-edelweiss.cloud" = {
        # Nextcloud
        addSSL = true;
        enableACME = true;
      };

      "virgilribeyre.com" = {
        addSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            root = "${virgilribeyre-package}";
            index = "index.html";
          };
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
