{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.inadyn;

  dataDir = "inadyn";
  StateDirectory = "/var/inadyn";
  RuntimeDirectory = "/run/${dataDir}";


  configText = pkgs.writeText "inadyn.conf" (''
  # In-a-Dyn is a dynamic DNS client with multiple SSL/TLS library support
  # Generated by Nix
  # See inadyn.conf(5)

  '' + cfg.settings);

  configFile = "${RuntimeDirectory}/inadyn.conf";

  preStart = if (cfg.passwordFile != null) then ''
  mkdir -p ${RuntimeDirectory}
  install --mode=600 --owner=$USER ${configText} ${configFile}
  "${pkgs.replace-secret}/bin/replace-secret" "${cfg.passwordPlaceholder}" "${cfg.passwordFile}" "${configFile}"
  '' else "";

  extraArgs = lib.strings.concatStringSep " " ([
    "--foreground"
    "--syslog"
    "--no-pidfile"
  ] ++ cfg.extraArgs);
in
  {
    options.services.inadyn = {
      enable = mkEnableOption "Inadyn dynamic DNS client";

      package = mkOption {
        type = types.package;
        default = pkgs.inadyn;
        defaultText = literalExpression "pkgs.inadyn";
        description = ''
        Inadyn package to install.
        '';
      };

      settings = mkOption {
        type = types.str;
        default = "";
        description = "Configuration options for Inadyn.";
        example = literalExpression ''
        period          = 300
        user-agent      = Mozilla/5.0

        provider freedns {
          username    = lower-case-username
          password    = case-sensitive-pwd
          hostname    = some.example.com
        }
        '';
      };

      passwordPlaceholder = mkOption {
        default = "@password_placeholder@";
        type = types.nonEmptyStr;
        description = "The password placeholder to use with the password file.";
        example = "@secret_password@";
      };

      passwordFile = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = lib.mdDoc ''
        A file containing the password for your `@password_placeholder@` field
          in `services.inadyn.settings`.
          '';
        };

        extraArgs = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Extra arguments when running Inadyn.";
          example = literalExpression "--force";
        };
      };

      config = mkIf cfg.enable {
        systemd.services.inadyn = {
          description = "Internet Dynamic DNS Client";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          requires = [ "network-online.target" ];
          restartTriggers = optional (cfg.settings != null) configText;

          serviceConfig = {
            Type = "simple";
            User = "root";
            RuntimeDirectoryMode = "0700";
            inherit RuntimeDirectory StateDirectory;
            ExecStartPre = "!${pkgs.writeShellScript "inadyn-prestart" preStart}";
            ExecStart = "${lib.getBin cfg.package}/bin/inadyn -f ${configFile} ${extraArgs}";
          };
        };
      };
    }

