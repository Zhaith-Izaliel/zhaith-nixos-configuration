{ config, pkgs, ... }:

{
  imports = [
    ./nextcloud.nix
    ./nginx.nix
    ./jellyfin.nix
    ./fail2ban.nix
    ./ddclient.nix
    ./calibre.nix
    #./minecraftServer.nix
  ];
}