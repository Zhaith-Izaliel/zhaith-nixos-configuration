{ config, pkgs, ... }:

{
  # Git dot file
  programs.git = {
    enable = true;
    userName = "Virgil Ribeyre";
    userEmail = "virgil.ribeyre@protonmail.com";
    extraConfig = {
      push.autoSetupRemote = true;
      init.defaultBranch = "master";
      pull.rebase = false;
    };
  };
}