{ config, ... }:

{
  hellebore = {

    fontSize = 14;

    desktop-environment = {
      hyprland = {
        enable = true;
        monitors = [
          {
            name = "eDP-1";
            width = 2560;
            height = 1440;
            refreshRate = 165;
            xOffset = 0;
            yOffset = 0;
            scaling = 1.0;
          }
        ];
        lockscreen = {
          enable = true;
          fontSize = config.hellebore.fontSize + 10;
        };
        logout = {
          enable = true;
          fontSize = 20;
        };
        applications-launcher = {
          enable = true;
        };
        notifications.enable = true;
        status-bar = {
          enable = true;
          fontSize = 12;
          backlight-device = "intel_backlight";
        };
      };
      bluetooth.enable = true;
      network.enable = true;
      cloud.enable = true;
      i18n = {
        enable = true;
        enableAnthy = true;
      };
      files-manager = {
        enable = true;
        supports = {
          images = true;
          torrents = true;
          archives = true;
          fonts-viewer = true;
        };
      };
      disks.enable = true;
      mail = {
        enable = true;
        protonmail.enable = true;
      };
      browsers = {
        enable = true;
        profiles.zhaith.enable = true;
      };
    };

    tools = {
      discord = {
        enable = true;
        betterdiscord.enable = true;
      };
      office.enable = true;
    };

    multimedia = {
      enable = true;
      art.enable = true;
      obs.enable = true;
      mpd = {
        enable = true;
        enableDiscordRPC = true;
        visualizer = {
          enable = true;
          spectrumSmoothLook = true;
        };
      };
    };

    development = {
      git = {
        enable = true;
        gitui.enable = true;
        commitlint.enable = true;
        ghq.enable = true;
        h.enable = true;
      };
      erdtree = {
        enable = true;
      };
      bat.enable = true;
      tools = {
        enable = true;
        enableLorri = true;
      };
    };

    shell = {
      enable = true;
      motd.enable = true;
      prompt.enable = true;
      emulator = {
        enable = true;
        integratedGPU = {
          enable = true;
          driver = "i915";
        };
      };
    };
  };

  programs.neovim.zhaith-config.enable = true;
}

