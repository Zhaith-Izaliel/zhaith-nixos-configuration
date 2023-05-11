{ config, pkgs, ... }:

let
  # IMPORTANT Update these values for your vms and your wanting core isolation
  totalCores = "0-15";
  hostCores = "0-3,8-11";
  vmCores = "4-7,12-15"; # NOTE This variable isn't used, but help defining isolated cores
  vmName = "Luminous-Rafflesia";
  # NOTE This variable is used in the script start-vm
  isolateCpuVariableName = "ISOLATE_CPUS";
in
{
  environment.systemPackages = with pkgs; [
    virtmanager
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      ovmf.enable = true;
      runAsRoot = true;
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
    libvirtHooks = "/var/lib/libvirt/hooks";
  in ''
    mkdir -p "${libvirtHooks}"
    chmod 755 "${libvirtHooks}"

    # Copy hook files
    ln -sf ${qemuHook} "${libvirtHooks}/qemu"
  '';
}