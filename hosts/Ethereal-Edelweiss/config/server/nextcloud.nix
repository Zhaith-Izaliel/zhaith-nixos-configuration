{pkgs, ...}: {
  # Actual Nextcloud Config
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.ethereal-edelweiss.cloud";
    home = "/mnt/datas/nextcloud";

    # Use HTTPS for links
    https = true;

    # Nextcloud Version
    package = pkgs.nextcloud26;

    # IMPORTANT set it to true if using server-side encryption
    enableBrokenCiphersForSSE = false;

    # Auto-update Nextcloud Apps
    autoUpdateApps.enable = true;
    # Set what time makes sense for you
    autoUpdateApps.startAt = "02:00:00";

    # Max upload size for files
    maxUploadSize = "10G";

    phpOptions = {
      catch_workers_output = "yes";
      display_errors = "stderr";
      error_reporting = "E_ALL & ~E_DEPRECATED & ~E_STRICT";
      expose_php = "Off";
      "opcache.enable_cli" = "1";
      "opcache.fast_shutdown" = "1";
      "opcache.interned_strings_buffer" = "16";
      "opcache.max_accelerated_files" = "10000";
      "opcache.memory_consumption" = "128";
      "opcache.revalidate_freq" = "1";
      "openssl.cafile" = "/etc/ssl/certs/ca-certificates.crt";
      short_open_tag = "Off";
    };

    config = {
      # Further forces Nextcloud to use HTTPS
      overwriteProtocol = "https";

      # Nextcloud PostegreSQL database configuration, recommended over using SQLite
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";

      adminpassFile = "/mnt/datas/nextcloud/nextcloud-admin-pass";
      dbpassFile = "/mnt/datas/nextcloud/nextcloud-db-pass";
      adminuser = "Zhaith";
      defaultPhoneRegion = "FR";
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = ["nextcloud"];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions."DATABASE \"nextcloud\"" = "ALL PRIVILEGES";
      }
    ];
  };

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };

  # Give access in write and read for nextcloud group in /mnt/datas/nextcloud
  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/15 * * * *  root  chmod g+rw -R /mnt/datas/nextcloud"
    ];
  };
}
