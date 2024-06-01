{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkOption types mkIf mkDefault;
  cfg = config.hellebore.server.factorio;
  domain = "${cfg.subdomain}.${config.networking.domain}";
in {
  options.hellebore.server.factorio =
    {
      mods = mkOption {
        type = types.listOf types.package;
        default = [];
        description = ''
          Mods the server should install and activate.

          The derivations in this list must "build" the mod by simply copying
          the .zip, named correctly, into the output directory. Eventually,
          there will be a way to pull in the most up-to-date list of
          derivations via nixos-channel. Until then, this is for experts only.
        '';
      };

      mods-dat = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Mods settings can be changed by specifying a dat file, in the [mod
          settings file
          format](https://wiki.factorio.com/Mod_settings_file_format).
        '';
      };

      admins = mkOption {
        type = types.listOf types.str;
        default = [];
        example = ["username"];
        description = ''
          List of player names which will be admin.
        '';
      };

      extraSettingsFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          File, which is dynamically applied to server-settings.json before
          startup.

          This option should be used for credentials.

          For example a settings file could contain:
          ```json
          {
            "game-password": "hunter1"
          }
          ```
        '';
      };
    }
    // extra-types.server-app {
      name = "Factorio Server";
      package = "factorio-headless";
      port = 34197;
    };

  config = mkIf cfg.enable {
    services.factorio = {
      inherit (cfg) package port mods admins extraSettingsFile mods-dat;
      enable = true;
      openFirewall = true;
    };

    hellebore.server.nginx.enable = mkDefault true;
    services.nginx.streamConfig = ''
      server {
        listen 127.0.0.1:${toString cfg.port} udp reuseport;
        proxy_pass ${domain}:${toString cfg.port};
      }
    '';
  };
}
