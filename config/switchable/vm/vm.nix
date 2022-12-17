{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    virtmanager
    cpuset
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

  systemd.services.libvirtd.preStart = let
    qemuHook = pkgs.writeScript "qemu-hook" ''
      #!${pkgs.stdenv.shell}
      TOTAL_CORES='0-15'
      HOST_CORES='0-3,8-11'           # Cores reserved for host
      VIRT_CORES='4-7,12-15'          # Cores reserved for virtual machine(s)
      WINDOWS_VM_NAME="Luminous-Rafflesia"

      VM_NAME="$1"
      VM_ACTION="$2/$3"
      if [ "$VM_NAME" = "$WINDOWS_VM_NAME" ] && [ "$ISOLATE_CPUS" = "true" ]; then
        if [[ "$VM_ACTION" == "prepare/begin" ]]; then
            systemctl set-property --runtime -- user.slice AllowedCPUs=$HOST_CORES
            systemctl set-property --runtime -- system.slice AllowedCPUs=$HOST_CORES
            systemctl set-property --runtime -- init.scope AllowedCPUs=$HOST_CORES
        elif [[ "$VM_ACTION" == "release/end" ]]; then
            systemctl set-property --runtime -- user.slice AllowedCPUs=$TOTAL_CORES
            systemctl set-property --runtime -- system.slice AllowedCPUs=$TOTAL_CORES
            systemctl set-property --runtime -- init.scope AllowedCPUs=$TOTAL_CORES
        fi
      fi
    '';
  in ''
    mkdir -p /var/lib/libvirt/hooks
    chmod 755 /var/lib/libvirt/hooks

    # Copy hook files
    ln -sf ${qemuHook} /var/lib/libvirt/hooks/qemu
  '';
}