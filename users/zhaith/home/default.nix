{ config, ... }:

{

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0" # Obsidian
  ];

  hellebore = {

    theme.name = "catppuccin";

    desktop-environment = {
      hyprland = {
        enable = true;
        mirrorFirstMonitor = true;
      };

      lockscreen = {
        enable = true;
        font.size = config.hellebore.font.size + 10;
        timeouts = {
          dim.enable = true;
          lock.enable = true;
          powerSaving.enable = true;
        };
      };

      logout = {
        enable = true;
        font.size = 20;
      };

      applications-launcher = {
        enable = true;
      };

      notifications.enable = true;

      status-bar = {
        enable = true;
        font.size = 11;
        backlight-device = "intel_backlight";
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
        firefoxDev.enable = true;
      };
    };

    tools = {
      discord = {
        enable = true;
        openASAR.enable = true;
        tts.enable = true;
      };
      office.enable = true;
      tasks.enable = true;
      docs.enable = true;
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

    games = {
      dxvk = {
        enable = true;
        config = ''
          [HuntGame.exe]
          dxvk.enableGraphicsPipelineLibrary = True
        '';
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
        direnv = {
          enable = true;
        };
      };
    };

    shell = {
      enable = true;
      motd.enable = true;
      prompt.enable = true;
      emulator = {
        enable = true;
        integratedGPU = {
          enable = false;
          driver = "iris";
        };
      };
    };
  };

  programs.neovim.zhaith-config.enable = true;
}

