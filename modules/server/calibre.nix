{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkPackageOption mkIf cleanSource;
  cfg = config.hellebore.server.calibre-web;
in {
  options.hellebore.server.calibre-web = {
    enable = mkEnableOption "Hellebore's Calibre-Web configuration";

    package = mkPackageOption pkgs "calibre-web" {};

    group = mkOption {
      type = types.nonEmptyStr;
      default = "";
      description = "Defines the user group to access the library.";
    };

    library = mkOption {
      type = types.path;
      default = cleanSource /var/calibre/library;
      description = "";
    };

    subdomain = mkOption {
      type = types.nonEmptyStr;
      default = "calibre";
      description = "Defines the subdomain on which Calibre-Web is running.";
    };

    acmeEmail = mkOption {
      type = types.nonEmptyStr;
      default = "";
      description = "Defines the email used for ACME SSL certificates.";
    };
  };

  config = mkIf cfg.enable {
    services.calibre-web = {
      enable = true;
      group = "nextcloud";
      options.calibreLibrary = "/mnt/datas/nextcloud/data/Zhaith/files/Books";
    };
  };
}
