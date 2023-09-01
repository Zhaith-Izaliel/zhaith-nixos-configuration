{ config, lib, inputs, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.hyprland.applications-launcher;
  anyrun-plugins = inputs.anyrun.packages.${pkgs.system};
in
{
  options.hellebore.desktop-environment.hyprland.applications-launcher = {
    enable = mkEnableOption "Hellebore Anyrun configuration";

    plugins.enable = mkEnableOption "Enable Anyrun plugins";
  };

  config = mkIf cfg.enable {
    programs.anyrun = {
      enable = true;

      config = {
        plugins = lists.optionals cfg.plugins.enable (with anyrun-plugins; [
          applications
          rink
          translate
          randr
          dictionary
        ]);
        width = { fraction = 0.5; };
        height = { fraction = 0.5; };
        x = { fraction = 0.5; };
        y = { fraction = 0.5; };
        hideIcons = false;
        ignoreExclusiveZones = true;
        layer = "overlay";
        hidePluginInfo = true;
        closeOnClick = true;
        showResultsImmediately = true;
        maxEntries = 5;
      };

      extraCss = ''
      window:after {
        opacity: 0.5;
      }
      '';

      extraConfigFiles."applications.ron".text = strings.optionalString cfg.plugins.enable ''
      Config(
        desktop_actions = true,
        max_entries = 5,
        terminal: Some("kitty"),
      )
      '';
    };
  };
}

