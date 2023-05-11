{ config, pkgs, ...}:

{
  services.jellyfin = {
    enable = true;
    group = "nextcloud";
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/15 * * * *  root  chmod g+rw -R /mnt/datas/nextcloud"
    ];
  };
}