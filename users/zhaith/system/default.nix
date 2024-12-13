{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) optional;
in {
  # Define user accounts. Don't forget to set a password with ‘passwd’.

  users.groups.zhaith = {};

  users.users.zhaith = {
    isNormalUser = true;
    extraGroups =
      [
        "wheel" # 'wheel' Enable ‘sudo’ for the user.
        "scanner"
        "lp"
        "podman"
        "video"
      ]
      ++ (optional config.hellebore.games.gamemode.enable "gamemode")
      ++ (optional config.hellebore.games.enabled "games");
    group = "zhaith";
    description = "Virgil Ribeyre";
    shell = pkgs.zsh;
  };
}
