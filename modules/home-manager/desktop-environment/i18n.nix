{ config, lib, pkgs, theme, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.i18n;
in
{
  options.hellebore.desktop-environment.i18n = {
    enable = mkEnableOption "Hellebore's Fcitx5 configuration";

    package = mkOption {
      type = types.package;
      default = pkgs.fcitx5;
      description = "The fcitx5 package.";
    };

    enableAnthy = mkEnableOption "Anthy input method";
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
      ] ++ (if cfg.enableAnthy then pkgs.fcitx5-anthy else []);
    };

    xdg.configFile."fcitx5/conf/classicui.conf".text = ''
      # Vertical Candidate List
      Vertical Candidate List=False

      # Use Per Screen DPI
      PerScreenDPI=True

      # Use mouse wheel to go to prev or next page
      WheelForPaging=True

      # Font
      Font="${theme.gtk.font.name} ${toString theme.gtk.font.size}"

      # Menu Font
      MenuFont="${theme.gtk.font.name} ${toString theme.gtk.font.size}"

      # Tray Font
      TrayFont="${theme.gtk.font.name} Bold ${toString theme.gtk.font.size}"

      # Tray Label Outline Color
      TrayOutlineColor=${colors.mantle}

      # Tray Label Text Color
      TrayTextColor=${colors.text}

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

