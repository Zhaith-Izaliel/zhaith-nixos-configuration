{
  config,
  lib,
  pkgs,
  options,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption mkOption types;
  cfg = config.hellebore.ssh-agent;
in {
  options.hellebore.ssh-agent = {
    inherit (options.programs.keychain) agents inheritType keys;

    enable = mkEnableOption "SSH agent using Keychain";

    package = mkPackageOption pkgs "keychain" {};

    extraArgs = mkOption {
      type = types.listOf types.nonEmptyStr;
      default = [
        "--quiet"
      ];
      description = "Extra arguments to pass to Keychain.";
    };
  };

  config = mkIf cfg.enable {
    programs.keychain = {
      inherit (cfg) package agents inheritType keys;
      enable = true;
      enableZshIntegration = config.programs.zsh.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableBashIntegration = config.programs.bash.enable;
      enableNushellIntegration = config.programs.nushell.enable;

      extraFlags = cfg.extraArgs;
    };
  };
}
