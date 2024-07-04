{...}: {
  imports = [
    ./acme.nix
    ./calibre.nix
    ./factorio.nix
    ./fail2ban.nix
    ./inadyn.nix
    ./invoiceshelf.nix
    ./jellyfin.nix
    ./nextcloud.nix
    ./nginx.nix
    ./podman.nix
    ./postgresql.nix
    ./servas.nix
    ./virgilribeyre-com.nix
  ];

  # config = {
  #   boot.enableContainers = false;
  # };
}
