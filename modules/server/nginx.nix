{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkPackageOption mkEnableOption mkIf;
  cfg = config.hellebore.server.nginx;
in {
  options.hellebore.server.nginx = {
    enable = mkEnableOption "Hellebore's NGINX reverse proxy configuration";

    package = mkPackageOption pkgs "nginx" {};
  };

  config = mkIf cfg.enable {
    services.nginx = {
      inherit (cfg) enable package;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      serverNamesHashBucketSize = 64;
    };
  };
}
