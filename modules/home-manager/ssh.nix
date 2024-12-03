{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types mkPackageOption;
  cfg = config.hellebore.ssh-agent;
in {
  options.hellebore.ssh-agent = {
    enable = mkEnableOption "SSH agent using GPG";

    package = mkPackageOption pkgs "gnupg" {};

    homedir = mkOption {
      default = "${config.xdg.dataHome}/gnupg";
      type = types.nonEmptyStr;
      description = "Directory to store keychains and configuration.";
    };
  };

  config = mkIf cfg.enable {
    programs.gpg = {
      inherit (cfg) homedir package;
      enable = true;
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };
}
