{config, ...}: {
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0" # Obsidian
  ];

  hellebore = {
    theme.name = "catppuccin";

    locale.enable = true;

    desktop-environment = {
      clipboard.enable = true;

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
        font.name = "NotoMono Nerd Font";

        applets = let
          defaultAppletSettings = {
            font = {
              inherit (config.hellebore.desktop-environment.applications-launcher.font) size;
              name = "FiraCode Nerd Font Mono";
            };
            width = "1000px";
            height = "600px";
          };
        in {
          favorites = defaultAppletSettings;
          quicklinks = defaultAppletSettings;
          bluetooth = defaultAppletSettings;
          mpd = defaultAppletSettings;
          power-profiles = defaultAppletSettings;
        };
      };

      notifications.enable = true;

      status-bar = {
        enable = true;
        font.size = 11;
        backlight-device = "intel_backlight";
        tray = {
          icon-size = 22;
          spacing = 5;
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

    development = {
      git = {
        enable = true;
        gitui.enable = true;
        commitizen = {
          enable = true;
          setUpAlias = true;
        };
        commitlint.enable = true;
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
      prompt.enable = true;
      workspace.enable = true;
      emulator = {
        enable = true;
        integratedGPU = {
          enable = false;
          driver = "iris";
        };
      };
    };
  };

  # programs.neovim.zhaith-config.enable = true;
  programs.helix.zhaith-configuration = {
    enable = true;
    defaultEditor = true;
  };
}
