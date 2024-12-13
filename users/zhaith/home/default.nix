{
  config,
  pkgs,
  lib,
  unstable-pkgs,
  os-config,
  ...
}: let
  inherit (lib) optionalString getExe optional range cleanSource flatten;
in {
  hellebore = {
    theme.name = "catppuccin-macchiato";

    locale.enable = true;

    dev-env = {
      helix = {
        enable = true;
        defaultEditor = true;
        settings = {
          languages = let
            flakeUrl = "gitlab:Zhaith-Izaliel/zhaith-nixos-configuration/develop";
            nixosConfigName = "Whispering-Willow";
            homeConfigName = "zhaith@Whispering-Willow";
          in {
            language-server.nixd.config.nixd = {
              nixpkgs.expr = ''import (builtins.getFlake "${flakeUrl}").inputs.nixpkgs-unstable {}'';
              options = {
                nixos.expr = ''(builtins.getFlake "${flakeUrl}").nixosConfigurations.${nixosConfigName}.options'';
                home_manager.expr = ''(builtins.getFlake "${flakeUrl}").homeConfigurations."${homeConfigName}".options'';
              };
            };
          };
        };
      };

      zellij = {
        enable = true;
        packages.zellij = unstable-pkgs.zellij;
        shellIntegrations.zsh = true;
        layoutAlias = true;
        enableSideBar = true;
        autoAttach = true;
      };
      yazi = {
        enable = true;
        shellIntegrations.zsh = true;
      };
      erdtree.enable = true;
    };

    desktop-environment = {
      clipboard.enable = true;

      nightlights.enable = true;

      hyprland = {
        enable = true;

        cursorSize = 18;

        input = {
          mouse.scrollFactor = 0.85;
          touchscreen.enable = true;
        };

        picture-in-picture = {
          enable = true;
          position = "top-right";
        };

        extraExecOnce = [
          (optionalString config.hellebore.desktop-environment.browsers.enable "[workspace 1] ${getExe config.hellebore.desktop-environment.browsers.package}")
          (optionalString config.hellebore.shell.emulator.enable "[workspace 1] ${config.hellebore.shell.emulator.bin}")
          (optionalString config.hellebore.tools.discord.enable "[workspace 3] ${getExe config.hellebore.tools.discord.finalPackage}")
          (optionalString config.hellebore.desktop-environment.mail.enable "[workspace 4] ${getExe config.hellebore.desktop-environment.mail.package}")
          (optionalString os-config.hellebore.games.steam.enable "[workspace 5] ${getExe os-config.hellebore.games.steam.package} -silent")
          (optionalString os-config.hellebore.games.cartridges.enable "[workspace 5] ${getExe os-config.hellebore.games.cartridges.package}")
        ];

        extraWorkspaceRules = builtins.map (
          item: {
            selector = toString item;
            rules = ["persistent:true"] ++ (optional (item == 1) "default:true");
          }
        ) (range 1 5);

        switches = {
          lid = {
            enable = true;
          };
        };

        progressiveWebApps = {
          outline = {
            id = "01JESC6QZSGR7VASS75KY9ZQ9T";
            execRules = [
              "workspace 2 silent"
            ];
            windowRules = [
              "workspace 2"
            ];
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
          flatten [
            (optional os-config.hellebore.games.steam.enable {
              regex = "class:(steam)";
              rules = [
                "workspace 5 silent"
              ];
            })

            {
              regex = "class:(steam_app_).*";
              rules = gameRules;
            }

            (optional os-config.hellebore.games.lutris.enable {
              regex = "class:(lutris)";
              rules = [
                "workspace 5"
              ];
            })

            (optional os-config.hellebore.games.cartridges.enable {
              regex = "class:^.*(Cartridges).*$";
              rules = [
                "workspace 5"
              ];
            })

            {
              regex = "class:(vesktop|discord)";
              rules = [
                "workspace 3 silent"
              ];
            }
            {
              regex = "class:(factorio).*";
              rules = gameRules;
            }
            {
              regex = "class:(steam_app_).*";
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
          suspend.enable = false;
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

      notifications = {
        enable = true;

        height = 200;
      };

      status-bar = {
        enable = true;
        font.size = 11;
        backlight-device = "amdgpu_bl1";
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
      };

      browsers = {
        enable = true;
        package = pkgs.firefox-bin;
        profiles.zhaith.enable = true;
        progressiveWebApps.enable = true;
      };
    };

    ssh-agent = {
      enable = true;
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
      sonobus = {
        enable = true;
        service = {
          enable = true;
          groupName = "Cordyceps-Sound-Sharing";
          setupFile = cleanSource ./sonobus/zhaith-at-whispering-willow.xml;
        };
      };

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

      game-development = {
        godot.enable = true;
      };
    };

    shell = {
      enable = true;
      enableImageSupport = true;
      prompt.enable = true;
      emulator = {
        enable = true;
      };
    };
  };
}
