{pkgs, ...}: {
  # Define user accounts. Don't forget to set a password with ‘passwd’.

  users.groups.zhaith = {
    name = "zhaith";
  };

  users.users.zhaith = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # 'wheel' Enable ‘sudo’ for the user.
      "kvm"
      "libvirt"
      "libvirtd"
      "qemu-libvirtd"
      "scanner"
      "lp"
      "podman"
      "video"
    ];
    group = "zhaith";
    description = "Virgil Ribeyre";
    shell = pkgs.zsh;
  };
}
