{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.vm;
in
{
  options.hellebore.vm = {
    enable = mkEnableOption "Hellebore KVM VM (*Works only with an Intel CPU and
    Nvidia GPU)";

    cpuIsolation = {
      enable = mkEnableOption "CPU isolation";

      totalCores = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "Total CPU cores in the form `n-m`";
      };

      hostCores = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "Host CPU when the vm runs.";
      };

      variableName = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "Name of the variable used in your starting VM script to
        allow CPU isolation";
      };
    };

    name = mkOption {
      type = types.nonEmptyStr;
      default = "";
      description = "Name of the VM in virt-manager";
    };

    pcisBinding = {
      enableOnBoot = mkEnableOption "PCIs binding on Boot";

      enableDynamicBinding = mkEnableOption "PCIs dynamic binding on VM run
      (Nvidia only)";

      pcis = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
        description = "List of the PCIs to isolate the GPU.";
      };
    };



    username = mkOption {
      type = types.nonEmptyStr;
      default = "";
      description = "Username for sound passthrough with pipewire.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> (builtins.length cfg.pcisBinding.pcis) > 0;
        message = "You need at least one PCI to allow GPU passthrough.";
      }
      {
        assertion = cfg.pcisBinding.enableOnBoot ->
        !cfg.pcisBinding.enableDynamicBinding;
        message = "You can't enable dynamic PCIs binding and binding on boot at the
        same time.";
      }
      {
        assertion = !cfg.pcisBinding.enableOnBoot ->
        cfg.pcisBinding.enableDynamicBinding;
        message = "You can't enable dynamic PCIs binding and binding on boot at the
        same time.";
      }
    ];

    environment.systemPackages = with pkgs; [
      virt-manager
      start-vm
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

    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 ${cfg.username} qemu-libvirtd -"
    ];

    systemd.services.libvirtd.preStart = let
      qemuHook = pkgs.writeScript "qemu-hook" ''
        #!${pkgs.stdenv.shell}
        VM_NAME="$1"
        VM_ACTION="$2/$3"
        if [ "$VM_NAME" = "${cfg.name}" ] && [ "${cfg.cpuIsolation.variableName}" = "true" ]; then
          if [[ "$VM_ACTION" == "prepare/begin" ]]; then
            systemctl set-property --runtime -- user.slice AllowedCPUs="${cfg.cpuIsolation.hostCores}"
            systemctl set-property --runtime -- system.slice AllowedCPUs="${cfg.cpuIsolation.hostCores}"
            systemctl set-property --runtime -- init.scope AllowedCPUs="${cfg.cpuIsolation.hostCores}"
            ${strings.optionalString cfg.pcisBinding.enableDynamicBinding ''
            # TODO: pci binding to vfio_pci and unbind from nvidia
            ''}
          elif [[ "$VM_ACTION" == "release/end" ]]; then
            systemctl set-property --runtime -- user.slice AllowedCPUs="${cfg.cpuIsolation.totalCores}"
            systemctl set-property --runtime -- system.slice AllowedCPUs="${cfg.cpuIsolation.totalCores}"
            systemctl set-property --runtime -- init.scope AllowedCPUs="${cfg.cpuIsolation.totalCores}"
            ${strings.optionalString cfg.pcisBinding.enableDynamicBinding ''
            # TODO: pci binding to nvidia and unbind from vfio_pci
            ''}
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

    boot = {
      kernelModules = [
        "kvm-intel"
        "vfio"
        "vfio_iommu_type1"
        "vfio_pci"
        "vfio_virqfd"
        "vhost-net"
      ];
      kernelParams = [
        "intel_iommu=on"
        "iommu=pt"
      ];
      initrd = mkIf cfg.pcisBinding.enableOnBoot {
        availableKernelModules = [
          "vfio"
          "vfio_iommu_type1"
          "vfio_pci"
          "vfio_virqfd"
          "vhost-net"
        ];


        preDeviceCommands = ''
          for DEV in ${strings.concatStringsSep " " cfg.pcisBinding.pcis}; do
          echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
          done
          modprobe -i vfio-pci
        '';
      };

      extraModprobeConfig = ''
        blacklist nouveau
        # blacklist xpad
        ${strings.optionalString cfg.pcisBinding.enableOnBoot "options nouveau modeset=0"}
      '';
    };
  };
}

