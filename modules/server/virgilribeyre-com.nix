{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.server.virgilribeyre-com;
  virgilribeyre-package = inputs.virgilribeyre-com.packages.${pkgs.system}.default;
in {
  options.hellebore.server.virgilribeyre-com = {
    enable = mkEnableOption "virgilribeyre.com";
  };

  config = mkIf cfg.enable {
    # virgilribeyre.com
    services.nginx.virtualHosts."virgilribeyre.com" = {
      enableACME = true;
      forceSSL = true;

      serverAliases = [
        "www.virgilribeyre.com"
      ];

      locations = {
        "/" = {
          root = "${virgilribeyre-package}";
          index = "index.html";
          tryFiles = "$uri $uri/ /index.html";
        };
      };
    };
  };
}
