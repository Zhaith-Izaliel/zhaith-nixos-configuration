{
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optional mkOption types;
  cfg = config.hellebore.desktop-environment.i18n;
  theme = config.hellebore.theme.themes.${cfg.theme};
  finalAddons = with pkgs;
    [
      fcitx5-gtk
      libsForQt5.fcitx5-qt
    ]
    ++ cfg.addons
    ++ optional cfg.enableAnthy pkgs.fcitx5-anthy;
  package = pkgs.libsForQt5.fcitx5-with-addons.override {addons = finalAddons;};
in {
  options.hellebore.desktop-environment.i18n = {
    enable = mkEnableOption "Hellebore's Fcitx5 configuration";

    enableAnthy = mkEnableOption "Anthy input method";

    package = mkOption {
      default = package;
      description = "The fcitx5 package to use.";
      type = types.package;
    };

    addons = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Addons added to Fcitx5.";
    };

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
      cfg.package
    ];

    home.sessionVariables = {
      QT_IM_MODULES = "wayland;fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      GLFW_IM_MODULE = "ibus"; # IME support in kitty
      GTK_IM_MODULE = "fcitx";
      QT_PLUGIN_PATH = "$QT_PLUGIN_PATH\${QT_PLUGIN_PATH:+:}${cfg.package}/${pkgs.qt6.qtbase.qtPluginPrefix}";
    };

    gtk = {
      gtk2.extraConfig = ''gtk-im-module="fcitx"'';
      gtk3.extraConfig = {gtk-im-module = "fcitx";};
      gtk4.extraConfig = {gtk-im-module = "fcitx";};
    };

    xdg.configFile."fcitx5/conf/classicui.conf".text =
      ''
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
      ''
      + theme.fcitx5.extraConfig;

    systemd.user.services.fcitx5-daemon = {
      Unit = {
        Description = "Fcitx5 input method editor";
        PartOf = ["graphical-session.target"];
      };
      Service.ExecStart = "${cfg.package}/bin/fcitx5";
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
