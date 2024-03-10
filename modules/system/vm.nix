{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    optionalString
    optionals
    concatStringsSep
    ;

  cfg = config.hellebore.vm;
  qemu-hook-script = pkgs.writeScript "qemu-hook" ''
    #!${pkgs.stdenv.shell}
    VM_NAME="$1"
    VM_ACTION="$2/$3"
    if [ "$VM_NAME" = "${cfg.name}" ]; then
      if [ "$VM_ACTION" = "prepare/begin" ]; then
        if [ "${cfg.cpuIsolation.variableName}" = "true" ]; then
          systemctl set-property --runtime -- user.slice AllowedCPUs="${cfg.cpuIsolation.hostCores}"
          systemctl set-property --runtime -- system.slice AllowedCPUs="${cfg.cpuIsolation.hostCores}"
          systemctl set-property --runtime -- init.scope AllowedCPUs="${cfg.cpuIsolation.hostCores}"
        fi

        ${optionalString cfg.pcisBinding.enableDynamicBinding ''
      modprobe -r nvidia_drm
      modprobe -i vfio_pci
    ''}
        elif [ "$VM_ACTION" = "release/end" ]; then

        if [ "${cfg.cpuIsolation.variableName}" = "true" ]; then
          systemctl set-property --runtime -- user.slice AllowedCPUs="${cfg.cpuIsolation.totalCores}"
          systemctl set-property --runtime -- system.slice AllowedCPUs="${cfg.cpuIsolation.totalCores}"
          systemctl set-property --runtime -- init.scope AllowedCPUs="${cfg.cpuIsolation.totalCores}"
        fi

        ${optionalString cfg.pcisBinding.enableDynamicBinding ''
      modprobe -r vfio_pci
      modprobe -i nvidia_drm
    ''}
      fi
    fi
  '';
in {
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

    useSecureBoot = mkEnableOption "Secure Boot on OVMF packages";

    pcisBinding = {
      enableDynamicBinding = mkEnableOption "PCIs dynamic binding on VM run
      (Nvidia only)";

      # pcis = mkOption {
      #   type = types.listOf types.nonEmptyStr;
      #   default = [];
      #   description = "List of the PCIs to isolate the GPU (should contain
      #   everything available in its IOMMU group).";
      # };

      vendorIds = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
        description = "List of the GPU vendor IDs to isolate it (should contain
        everything available in its IOMMU group).";
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
        assertion = cfg.enable -> (builtins.length cfg.pcisBinding.vendorIds) > 0;
        message = "You need at least one PCI to allow GPU passthrough.";
      }
    ];

    environment.systemPackages = with pkgs; [
      virt-manager
      start-vm
      win-virtio
    ];

    virtualisation = {
      spiceUSBRedirection.enable = true;

      libvirtd = {
        enable = true;
        qemu = {
          ovmf = {
            enable = true;
            packages = with pkgs; [
              (OVMFFull.override {
                secureBoot = cfg.useSecureBoot;
              })
              .fd
            ];
          };
          runAsRoot = true;
          verbatimConfig = ''
            user = "zhaith"
          '';
          swtpm.enable = true;
        };
        onBoot = "ignore";
        onShutdown = "shutdown";

        hooks.qemu = {
          qemu-hook = "${qemu-hook-script}";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 ${cfg.username} kvm -"
    ];

    boot = {
      kernelModules =
        [
          "kvm-intel"
          "vfio"
          "vfio_iommu_type1"
          "vfio_pci"
          "vhost-net"
        ]
        ++ optionals cfg.pcisBinding.enableDynamicBinding [
          "nvidia"
          "nvidia_modeset"
          "nvidia_uvm"
          "nvidia_drm"
        ];
      kernelParams = [
        "intel_iommu=on"
        "iommu=pt"
        ("vfio-pci.ids=" + concatStringsSep "," cfg.pcisBinding.vendorIds)
      ];
      initrd = {
        availableKernelModules =
          [
            "vfio"
            "vfio_iommu_type1"
            "vfio_pci"
            "vhost-net"
          ]
          ++ optionals cfg.pcisBinding.enableDynamicBinding [
            "nvidia"
            "nvidia_modeset"
            "nvidia_uvm"
            "nvidia_drm"
          ];
      };

      extraModprobeConfig = concatStringsSep "\n" [
        ''
          blacklist nouveau
          # blacklist xpad
        ''
        (optionalString (!cfg.pcisBinding.enableDynamicBinding) "options nouveau modeset=0")
        (optionalString cfg.pcisBinding.enableDynamicBinding ''
          remove vfio_pci
          install nvidia_drm
        '')
      ];
    };
  };
}
