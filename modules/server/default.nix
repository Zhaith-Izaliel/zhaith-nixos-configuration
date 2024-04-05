{...}: {
  imports = [
    ./calibre.nix
    ./fail2ban.nix
    ./inadyn.nix
    ./invoiceshelf.nix
    ./jellyfin.nix
    ./nextcloud.nix
    ./nginx.nix
    ./postgresql.nix
  ];

  config = {
    virtualisation.oci-containers.backend = "podman";
  };
}
