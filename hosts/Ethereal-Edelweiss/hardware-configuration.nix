# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e58c3672-a89b-463d-8796-662cb79f242b";
    fsType = "ext4";
  };

  fileSystems."/tmp" = {
    device = "/dev/disk/by-uuid/7b8d2737-2d9e-4a4f-b93a-0fbe89ac6167";
    fsType = "ext4";
  };

  fileSystems."/mnt/datas" = {
    device = "/dev/disk/by-uuid/42660197-334d-450d-bc4b-cc113b36eb5e";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3A1B-2C3C";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/586b3a93-8c57-4a6b-827c-a290d9205a8e";}
  ];
}
