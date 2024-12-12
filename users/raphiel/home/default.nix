{
  config,
  pkgs,
  lib,
  unstable-pkgs,
  os-config,
  ...
}: let
  inherit (lib) optional optionalString getExe flatten;
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

        input = {
          mouse.scrollFactor = 0.85;
        };

        picture-in-picture = {
          enable = true;
          position = "top-right";
        };

        extraExecOnce = [
          (optionalString config.hellebore.desktop-environment.browsers.enable "[workspace 1] ${getExe config.hellebore.desktop-environment.browsers.package}")
          (optionalString config.hellebore.shell.emulator.enable "[workspace 1] ${config.hellebore.shell.emulator.bin}")
          (optionalString os-config.hellebore.games.steam.enable "[workspace 2] ${getExe os-config.hellebore.games.steam.package} -silent")
          (optionalString os-config.hellebore.games.cartridges.enable "[workspace 2] ${getExe os-config.hellebore.games.cartridges.package}")
        ];

        extraWorkspaceRules = [
          {
            selector = "1";
            rules = ["persistent:true" "default:true"];
          }
          {
            selector = "2";
            rules = ["persistent:true"];
          }
        ];

        extraWindowRules = let
          gameRules = [
            "workspace 2"
            "idleinhibit"
            "noblur"
            "noborder"
            "noshadow"
          ];
        in
          flatten [
            {
              regex = "class:(steam_app_).*";
              rules = gameRules;
            }

            {
              regex = "class:(factorio).*";
              rules = gameRules;
            }

            (optional os-config.hellebore.games.steam.enable {
              regex = "class:(steam)";
              rules = [
                "workspace 2 silent"
              ];
            })

            (optional os-config.hellebore.games.gamescope.enable {
              regex = "class:(.gamescope-wrapped)";
              rules = [
                "workspace 2"
                "idleinhibit"
              ];
            })

            (optional os-config.hellebore.games.lutris.enable {
              regex = "class:(lutris)";
              rules = [
                "workspace 2"
              ];
            })

            (optional os-config.hellebore.games.heroic-launcher.enable {
              regex = "class:^.*(heroic).*$";
              rules = [
                "workspace 2"
              ];
            })

            (optional os-config.hellebore.games.cartridges.enable {
              regex = "class:^.*(Cartridges).*$";
              rules = [
                "workspace 2"
              ];
            })

            (optional os-config.hellebore.games.minecraft.enable {
              regex = "class:(Minecraft).*";
              rules =
                gameRules
                ++ [
                  "fullscreen"
                ];
            })
          ];
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

      browsers = {
        enable = true;
        package = pkgs.firefox-bin;
        profiles.zhaith.enable = true;
      };
    };

    ssh-agent = {
      enable = true;
    };

    tools = {
      docs.enable = true;
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
