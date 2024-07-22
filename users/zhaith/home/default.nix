{
  config,
  os-config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) optional;
in {
  hellebore = {
    theme.name = "catppuccin-macchiato";

    locale.enable = true;

    dev-env = {
      helix = {
        enable = true;
        defaultEditor = true;
      };
      zellij = {
        enable = true;
        shellIntegrations.zsh = true;
        layoutAlias = true;
        enableSideBar = true;
        autoAttach = true;
        layouts = {
          # rust.content = ../../../assets/zellij-layouts/rust.kdl;
        };
      };
      yazi = {
        enable = true;
        shellIntegrations.zsh = true;
      };
      erdtree.enable = true;
    };

    desktop-environment = {
      clipboard.enable = true;

      hyprland = {
        enable = true;
        input.mouse.scrollFactor = 1.0;
        picture-in-picture = {
          enable = true;
          position = "top-right";
        };
        switches = {
          lid = {
            enable = true;
          };
        };
        extraWindowRules = let
          gameRules = [
            "workspace 5"
            "idleinhibit"
            "noblur"
            "noborder"
            "noshadow"
          ];
        in
          [
            {
              regex = "class:(steam_app_).*";
              rules = gameRules;
            }
            {
              regex = "class:(gamescope).*";
              rules = gameRules;
            }
            # {
            #   regex = "class:(gw2).*";
            #   rules = gameRules;
            # }
            {
              regex = "class:(factorio).*";
              rules = gameRules;
            }
          ]
          ++ optional os-config.hellebore.games.minecraft.enable {
            regex = "class:(Minecraft).*";
            rules =
              gameRules
              ++ [
                "fullscreen"
              ];
          };
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
        useLayerBlur = true;
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
        # TEMP: Disabled until composition with ^ works again on french keyboards
        # enable = true;
        # enableAnthy = true;
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
        package = pkgs.firefox-bin;
        profiles.zhaith.enable = true;
      };
    };

    tools = {
      affine.enable = true;
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
      mpris.enable = true;
      art.enable = true;
      obs.enable = true;
      mpd = {
        enable = true;
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
        h.enable = true;
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
      enableImageSupport = true;
      prompt.enable = true;
      # workspace.enable = true;
      emulator = {
        enable = true;
      };
    };
  };

  # programs.neovim.zhaith-config.enable = true;
}
