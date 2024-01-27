{...}: {
  services.jellyfin = {
    enable = true;
    group = "nextcloud";
  };
}
