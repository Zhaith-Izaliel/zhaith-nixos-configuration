{...}: {
  imports = [
    ./acme.nix
    ./authelia.nix
    ./calibre.nix
    ./dashy.nix
    ./enclosed.nix
    ./factorio.nix
    ./fail2ban.nix
    ./ghost.nix
    ./homepage.nix
    ./inadyn.nix
    ./invoiceshelf.nix
    ./jellyfin.nix
    ./mailserver.nix
    ./mariadb.nix
    ./mealie.nix
    ./nextcloud.nix
    ./nginx.nix
    ./outline.nix
    ./podman.nix
    ./postgresql.nix
    ./radicale.nix
    ./vaultwarden.nix
    ./virgilribeyre-com.nix
  ];

  # config = {
  #   boot.enableContainers = false;
  # };
}
