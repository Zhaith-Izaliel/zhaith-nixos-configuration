{ config, pkgs, ...}:

{
  services.calibre-web = {
    enable = true;
    group = "nextcloud";
    options.calibreLibrary = "/mnt/datas/nextcloud/data/Zhaith/files/Books";
  };
}