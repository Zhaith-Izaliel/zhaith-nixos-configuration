# Boot loader config
{ config, pkgs, ... }:

let
  # IMPORTANT Change these pcis for your vm GPU (https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Ensuring_that_the_groups_are_valid)
  pcis = "0000:01:00.0 0000:01:00.1";
in
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
        for DEV in ${pcis}; do
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
