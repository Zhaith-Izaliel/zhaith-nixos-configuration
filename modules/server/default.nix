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
    ./postgresql.nix
    ./twentycrm.nix
    ./virgilribeyre-com.nix
  ];

  config = {
    virtualisation.oci-containers.backend = "podman";
    boot.enableContainers = false;
  };
}
