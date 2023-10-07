# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2409b750-54cc-4171-a551-e8592292d42f";
      fsType = "ext4";
    };

  # fileSystems."/mnt/windows" =
  #   { device = "/dev/disk/by-uuid/ddae6099-5aec-42a9-a073-2964fcda4f1d";
  #     fsType = "ntfs";
  #   };
  #
  # fileSystems."/mnt/games" =
  #   { device = "/dev/disk/by-uuid/1be740f8-ed1b-439b-8f96-f1835e1fbf22";
  #     fsType = "ntfs";
  #   };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/9f181965-f48e-4e6e-8dcf-e00695fda38c";
      fsType = "ext4";
    };

  fileSystems."/mnt/games" =
    { device = "/dev/disk/by-uuid/3DC7196A3AF67751";
      fsType = "ntfs-3g";
      options = [ "rw" "uid=1000"];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/37C9-C571";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/0e5f0870-489a-455d-bf56-28eccde7c6ce"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # high-resolution display
  # hardware.video.hidpi.enable = lib.mkDefault true;
}

