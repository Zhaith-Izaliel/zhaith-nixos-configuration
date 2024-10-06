{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.hellebore.ssh;
in {
  options.hellebore.ssh = {
    enable = mkEnableOption "Open SSH configuration";

    ports = mkOption {
      type = types.listOf types.int;
      default = [22];
      description = "Ports used by OpenSSH.";
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      inherit (cfg) ports;
      enable = true;

      openFirewall = true;

      settings = {
        PasswordAuthentication = false;
        LogLevel = "VERBOSE";
      };

      allowSFTP = true;
      sftpServerExecutable = "internal-sftp";
    };
  };
}
