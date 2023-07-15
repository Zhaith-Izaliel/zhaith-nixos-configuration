{ theme-packages, colors }:

{
  package = theme-packages.fcitx5-theme;

  fcitx5 = {
    theme = {
      xdgConfigFile = "fcitx5/conf/classicui.conf";
      content = ''
      # Vertical Candidate List
      Vertical Candidate List=False
      # Use Per Screen DPI
      PerScreenDPI=True
      # Use mouse wheel to go to prev or next page
      WheelForPaging=True
      # Font
      Font="Sans 10"
      # Menu Font
      MenuFont="Sans 10"
      # Tray Font
      TrayFont="Sans Bold 10"
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
      Theme=catppuccin-macchiato
      # Force font DPI on Wayland
      ForceWaylandDPI=0
      '';
    };
  };
}

