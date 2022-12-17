# Boot loader config
{ config, pkgs, ... }:

{
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
      #"pcie_aspm=off"
      #"pcie_acs_override=downstream,multifunction"
    ];
    initrd = {
      availableKernelModules = [
        "vfio"
        "vfio_iommu_type1"
        "vfio_pci"
        "vfio_virqfd"
        "vhost-net"
      ];

      kernelModules = [ "i915" ];

      preDeviceCommands = ''
        DEVS="0000:01:00.0 0000:01:00.1"
        for DEV in $DEVS; do
          echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
        done
        modprobe -i vfio-pci
      '';
    };
    extraModprobeConfig = ''
      blacklist nouveau
      options nouveau modeset=0
    '';
  };
}