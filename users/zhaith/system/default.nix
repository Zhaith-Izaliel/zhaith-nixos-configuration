{ config, pkgs, ... }:

{
  # Define user accounts. Don't forget to set a password with ‘passwd’.
  users.users.zhaith = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # 'wheel' Enable ‘sudo’ for the user.
      "kvm"
      "libvirtd"
      "qemu-libvirtd"
      "scanner"
      "lp"
    ];
    group = "zhaith";
    description = "Virgil Ribeyre";
    shell = pkgs.fish;
  };
}
