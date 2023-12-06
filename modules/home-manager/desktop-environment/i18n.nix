{ config, lib, pkgs, theme, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.i18n;
in
{
  options.hellebore.desktop-environment.i18n = {
    enable = mkEnableOption "Hellebore's Fcitx5 configuration";

    enableAnthy = mkEnableOption "Anthy input method";

    fontSize = mkOption {
      type = types.int;
      default = config.hellebore.fontSize;
      description = "Set Fcitx5 client font size.";
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
      Font="${theme.gtk.font.name} ${toString cfg.fontSize}"

      # Menu Font
      MenuFont="${theme.gtk.font.name} ${toString cfg.fontSize}"

      # Tray Font
      TrayFont="${theme.gtk.font.name} Bold ${toString cfg.fontSize}"

      # Tray Label Outline Color
      TrayOutlineColor=${theme.colors.mantle}

      # Tray Label Text Color
      TrayTextColor=${theme.colors.text}

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
    '';
  };
}

