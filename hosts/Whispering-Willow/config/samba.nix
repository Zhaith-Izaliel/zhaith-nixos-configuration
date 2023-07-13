{ ... }:

{
  services.samba = {
    enable = true;
    openFirewall = true;
  };

  services.gvfs.enable = true;
}

