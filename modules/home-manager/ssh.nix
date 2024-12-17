{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.hellebore.ssh-agent;
in {
  options.hellebore.ssh-agent = {
    enable = mkEnableOption "SSH agent";
  };

  config = mkIf cfg.enable {
    services.ssh-agent.enable = true;
  };
}
