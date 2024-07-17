{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkMerge mkIf types;
  cfg = config.hellebore.ssh;
in {
  options.hellebore.ssh = {
    enable = mkEnableOption "Hellebore SSH configuration";

    openssh = {
      enable = mkEnableOption "OpenSSH daemon";

      ports = mkOption {
        type = types.listOf types.int;
        default = [22];
        description = "Ports used by OpenSSH.";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
      # programs.ssh = {
      #   enableAskPassword = true;
      #   askPassword = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
      #   startAgent = true;
      # };
    })
    (mkIf cfg.openssh.enable {
      services.openssh = {
        inherit (cfg.openssh) ports;
        enable = true;
        openFirewall = true;
        settings = {
          PasswordAuthentication = false;
          LogLevel = "VERBOSE";
        };

        allowSFTP = true;
        sftpServerExecutable = "internal-sftp";
      };
    })
  ];
}
