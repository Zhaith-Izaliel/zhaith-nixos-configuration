{ config, pkgs, ... }:

let
  totalCores = "0-15";
  hostCores = "0-3,8-11";
  vmCores = "4-7,12-15";
  vmName = "Luminous-Rafflesia";
  isolateCpuVariableName = "ISOLATE_CPUS";
  libvirtHooks = "/var/lib/libvirt/hooks";
in
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

  systemd.services.libvirtd.preStart = let
    qemuHook = pkgs.writeScript "qemu-hook" ''
      #!${pkgs.stdenv.shell}

      VM_NAME="$1"
      VM_ACTION="$2/$3"
      if [ "$VM_NAME" = "${vmName}" ] && [ "${isolateCpuVariableName}" = "true" ]; then
        if [[ "$VM_ACTION" == "prepare/begin" ]]; then
            systemctl set-property --runtime -- user.slice AllowedCPUs="${hostCores}"
            systemctl set-property --runtime -- system.slice AllowedCPUs="${hostCores}"
            systemctl set-property --runtime -- init.scope AllowedCPUs="${hostCores}"
        elif [[ "$VM_ACTION" == "release/end" ]]; then
            systemctl set-property --runtime -- user.slice AllowedCPUs="${totalCores}"
            systemctl set-property --runtime -- system.slice AllowedCPUs="${totalCores}"
            systemctl set-property --runtime -- init.scope AllowedCPUs="${totalCores}"
        fi
      fi
    '';
  in ''
    mkdir -p "${libvirtHooks}"
    chmod 755 "${libvirtHooks}"

    # Copy hook files
    ln -sf ${qemuHook} "${libvirtHooks}/qemu"
  '';
}