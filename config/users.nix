{ config, pkgs, ... }:

{
  # Define user accounts. Don't forget to set a password with ‘passwd’.
  users.users = {
    zhaith = {
      isNormalUser = true;
      extraGroups = [ "wheel" "kvm" "libvirtd" "qemu-libvirtd" ]; # 'wheel' Enable ‘sudo’ for the user.
      group = "zhaith";
      description = "Virgil Ribeyre";
      useDefaultShell = true;
    };
  };
}