{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    virtmanager
  ];

  networking.firewall.interfaces.virbr0.allowedUDPPorts = [ 4010 ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      ovmf.enable = true;
      runAsRoot = false;
      verbatimConfig = ''
        user = "zhaith"
      '';
    };
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  #Looking Glass
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 zhaith qemu-libvirtd -"
  ];
}