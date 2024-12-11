{pkgs, ...}: {
  # Define user accounts. Don't forget to set a password with ‘passwd’.

  users.groups.zhaith = {};

  users.users.zhaith = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # 'wheel' Enable ‘sudo’ for the user.
      "scanner"
      "lp"
      "podman"
      "video"
      "gamemode"
    ];
    group = "zhaith";
    description = "Virgil Ribeyre";
    shell = pkgs.zsh;
  };
}
