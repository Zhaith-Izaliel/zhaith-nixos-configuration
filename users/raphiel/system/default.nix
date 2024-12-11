{pkgs, ...}: {
  # Define user accounts. Don't forget to set a password with ‘passwd’.

  users.groups.raphiel = {};

  users.users.raphiel = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # 'wheel' Enable ‘sudo’ for the user.
      "scanner"
      "lp"
      "podman"
      "video"
      "gamemode"
    ];
    group = "raphiel";
    description = "Raphiel Izaliel";
    shell = pkgs.zsh;
  };
}
