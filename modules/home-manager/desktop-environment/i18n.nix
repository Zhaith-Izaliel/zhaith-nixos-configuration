{ config, lib, pkgs, extra-types, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.i18n;
  theme = config.hellebore.theme.themes.${cfg.theme};
in
{
  options.hellebore.desktop-environment.i18n = {
    enable = mkEnableOption "Hellebore's Fcitx5 configuration";

    enableAnthy = mkEnableOption "Anthy input method";

    font = extra-types.font {
      size = config.hellebore.font.size;
      name = config.hellebore.font.name;
      sizeDescription = "Set Fcitx5 client font size.";
      nameDescription = "Set Fcitx5 client font family.";
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines the terminal emulator theme.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      theme.fcitx5.package
    ];

    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = [
        pkgs.fcitx5-gtk
        pkgs.libsForQt5.fcitx5-qt
      ] ++ lists.optional cfg.enableAnthy pkgs.fcitx5-anthy;
    };

    xdg.configFile."fcitx5/conf/classicui.conf".text = ''
      # Vertical Candidate List
      Vertical Candidate List=False

      # Use Per Screen DPI
      PerScreenDPI=True

      # Use mouse wheel to go to prev or next page
      WheelForPaging=True

      # Font
      Font="${cfg.font.name} ${toString cfg.font.size}"

      # Menu Font
      MenuFont="${cfg.font.name} ${toString cfg.font.size}"

      # Tray Font
      TrayFont="${cfg.font.name} Bold ${toString cfg.font.size}"

      # Prefer Text Icon
      PreferTextIcon=False

      # Show Layout Name In Icon
      ShowLayoutNameInIcon=True

      # Use input method language to display text
      UseInputMethodLangaugeToDisplayText=True

      # Theme
      Theme=${theme.fcitx5.name}

      # Force font DPI on Wayland
      ForceWaylandDPI=0
    '' + theme.fcitx5.extraConfig;
  };
}

