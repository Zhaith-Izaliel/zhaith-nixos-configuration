{pkgs, ...}: {
  users.groups.lilith = {};

  # Define user accounts. Don't forget to set a password with ‘passwd’.
  users.users.lilith = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "nextcloud"
    ]; # 'wheel' Enable ‘sudo’ for the user.
    group = "lilith";
    description = "Lilith Izaliel";
    shell = pkgs.zsh;
  };
}
