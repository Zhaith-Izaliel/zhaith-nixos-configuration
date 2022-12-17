{ config, pkgs, ... }:

{
  services.cron = {
    enable = true;
    systemCronJobs = [
      "50 2 * * *     root   power-management 10" # Shutdown system at 3am to save power during not used time.
    ];
  };
}