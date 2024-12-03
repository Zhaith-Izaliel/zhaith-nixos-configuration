{
  config,
  lib,
  pkgs,
  unstable-pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption optional;
  cfg = config.hellebore.desktop-environment.browsers;
in {
  options.hellebore.desktop-environment.browsers = {
    enable = mkEnableOption "Hellebore Browsers configuration";

    package = mkPackageOption pkgs "firefox" {};

    progressiveWebApps = {
      enable = mkEnableOption "PWA support in Firefox. You need to install the PWA extension on Firefox";

      package = mkPackageOption unstable-pkgs "firefoxpwa" {};
    };

    profiles.zhaith = {
      enable = mkEnableOption "Zhaith's Firefox profile";
    };
  };

  config = mkIf cfg.enable {
    programs.chromium.enable = true;

    home.packages = optional cfg.progressiveWebApps.enable cfg.progressiveWebApps.package;

    programs.firefox = {
      inherit (cfg) package;

      enable = true;

      nativeMessagingHosts = optional cfg.progressiveWebApps.enable cfg.progressiveWebApps.package;

      profiles."zhaith" = mkIf cfg.profiles.zhaith.enable {
        isDefault = true;
        search = {
          default = "Google";
          engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@np"];
            };

            "Nix Options" = {
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@no"];
            };

            "ProtonDB" = {
              urls = [
                {
                  template = "https://www.protondb.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              definedAliases = ["@pb"];
              iconUpdateURL = "https://www.protondb.com/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000; # every day
            };

            "YouTube" = {
              urls = [
                {
                  template = "https://www.youtube.com/results";
                  params = [
                    {
                      name = "search_query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              iconUpdateURL = "https://www.youtube.com/favicon.ico";
              definedAliases = ["@yt"];
            };

            "NixOS Wiki" = {
              urls = [
                {
                  template = "https://wiki.nixos.org/w/index.php";
                  params = [
                    {
                      name = "search";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              iconUpdateURL = "https://wiki.nixos.org/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = ["@nw"];
            };

            "Crates.io" = {
              urls = [
                {
                  template = "https://crates.io/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              iconUpdateURL = "https://crates.io/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = ["@cr"];
            };

            "Bing".metaData.hidden = true;
            "DuckDuckGo".metaData.hidden = true;
            "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
            "Wikipedia".metaData.alias = "@w";
          };
        };

        userChrome = ''
          .bookmark-item {
            margin-left: .25rem !important;
            margin-right: .25rem !important;
          }
        '';
      };
    };
  };
}
