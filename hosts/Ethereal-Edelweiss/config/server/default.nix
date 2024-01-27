{...}: {
  imports = [
    ./nextcloud.nix
    ./nginx.nix
    ./jellyfin.nix
    ./fail2ban.nix
    ./inadyn.nix
    ./calibre.nix
    #./minecraftServer.nix
  ];
}
