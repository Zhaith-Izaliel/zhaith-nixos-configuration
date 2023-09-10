{ config, lib, theme, pkgs, ... }:

with lib;

let
  getImage = name: cleanSource ../../../../assets/images/wlogout/${name};
  images = {
    lock = {
      default = getImage "lock.png";
      hover = getImage "lock-hover.png";
    };

    reboot = {
      default = getImage "reboot.png";
      hover = getImage "reboot-hover.png";
    };

    shutdown = {
      default = getImage "shutdown.png";
      hover = getImage "shutdown-hover.png";
    };

    logout = {
      default = getImage "logout.png";
      hover = getImage "logout-hover.png";
    };

    suspend = {
      default = getImage "suspend.png";
      hover = getImage "suspend-hover.png";
    };
  };
  cfg = config.hellebore.desktop-environment.hyprland.logout;
in
{
  options.hellebore.desktop-environment.hyprland.logout = {
    enable = mkEnableOption "Hellebore WLogout configuration";

    fontSize = mkOption {
      type = types.int;
      default = config.hellebore.fontSize;
      description = "Set the font size of the logout menu.";
    };

    bin = mkOption {
      type = types.str;
      default = "${getExe pkgs.wlogout-blur} --protocol layer-shell -b 5 -T 400 -B 400";
      readOnly = true;
      description  = "Define the command to run the logout program.";
    };
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

      style = ''
      window {
        font-family: "Fira Code";
        font-size: ${toString cfg.fontSize}pt;
        color: ${theme.colors.text};
        background-repeat: no-repeat;
        background-image: image(url("/tmp/wlogout-blur.png"));
      }

      button {
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
        border: none;
        background-color: rgba(30, 30, 46, 0);
        margin: 5px;
        transition: box-shadow 0.2s ease-in-out, background-color 0.2s ease-in-out;
      }

      button:hover {
        background-color: rgba(49, 50, 68, 0.1);
      }

      button:focus {
        background-color: ${theme.colors.mauve};
        color: ${theme.colors.base};
      }

      #lock {
        background-image: image(url("${images.lock.default}"));
      }
      #lock:focus {
        background-image: image(url("${images.lock.hover}"));
      }

      #logout {
        background-image: image(url("${images.logout.default}"));
      }
      #logout:focus {
        background-image: image(url("${images.logout.hover}"));
      }

      #suspend {
        background-image: image(url("${images.suspend.default}"));
      }
      #suspend:focus {
        background-image: image(url("${images.suspend.hover}"));
      }

      #shutdown {
        background-image: image(url("${images.shutdown.default}"));
      }
      #shutdown:focus {
        background-image: image(url("${images.shutdown.hover}"));
      }

      #reboot {
        background-image: image(url("${images.reboot.default}"));
      }
      #reboot:focus {
        background-image: image(url("${images.reboot.hover}"));
      }
      '';
    };
  };
}

