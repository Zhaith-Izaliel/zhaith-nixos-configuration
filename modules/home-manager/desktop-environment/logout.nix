{
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf getExe types mkPackageOption concatStringsSep;

  cfg = config.hellebore.desktop-environment.logout;

  package-name =
    if cfg.useLayerBlur
    then "wlogout"
    else "wlogout-blur";

  theme = config.hellebore.theme.themes.${cfg.theme};
in {
  options.hellebore.desktop-environment.logout = {
    enable = mkEnableOption "Hellebore logout screen configuration";

    font = extra-types.font {
      inherit (config.hellebore.font) name size;
      sizeDescription = "Set the font size of the logout menu.";
      nameDescription = "Set the font family of the logout menu.";
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines the logout screen theme.";
    };

    package = mkPackageOption pkgs package-name {};

    bin = mkOption {
      type = types.str;
      default = "${getExe cfg.package} ${concatStringsSep " " cfg.extraArgs}";
      readOnly = true;
      description = "Define the command to run the logout screen.";
    };

    extraArgs = mkOption {
      type = types.listOf types.nonEmptyStr;
      default = [
        "--protocol layer-shell"
        "-b 5"
        "-T 400"
        "-B 400"
      ];
      description = "Extra Arguments to pass to wlogout.";
    };

    useLayerBlur = mkEnableOption "use Hyprland layer rules to blur background, instead of a screenshot";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> config.programs.swaylock.enable;
        message = "WLogout depends on Swaylock to lock the screen. Please enable
        it in your configuration.";
      }
      {
        assertion = cfg.enable -> config.wayland.windowManager.hyprland.enable;
        message = "WLogout depends on Hyprland to logout. Please enable
        it in your configuration.";
      }
      {
        assertion = cfg.useLayerBlur -> config.wayland.windowManager.hyprland.enable;
        message = "WLogout layer blur depends on Hyprland to work properly. Please enable Hyprland in your configuration";
      }
    ];

    home.packages = with pkgs; [
      wlogout-blur
    ];

    programs.wlogout = {
      enable = true;
      layout = [
        {
          label = "lock";
          action = "${getExe config.programs.swaylock.package} -fF";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "reboot";
          action = "${pkgs.systemd}/bin/systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
        {
          label = "shutdown";
          action = "${pkgs.systemd}/bin/systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "logout";
          action = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch exit 0";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "suspend";
          action = "${pkgs.systemd}/bin/systemctl suspend";
          text = "Suspend";
          keybind = "u";
        }
      ];

      style =
        ''
          window {
            font-family: "${cfg.font.name}";
            font-size: ${toString cfg.font.size}pt;
            ${
            if (!cfg.useLayerBlur)
            then ''
              background-repeat: no-repeat;
              background-image: image(url("/tmp/wlogout-blur.png"));
            ''
            else ''
              background-color: transparent;
            ''
          }
          }

        ''
        + theme.wlogout.style;
    };
  };
}
