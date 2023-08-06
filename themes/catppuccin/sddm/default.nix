{ colors, gtk-theme, lib }:

{
  sddm = {
    settings = {
      General = {
        DisplayServer = "wayland";
      };

      Wayland = {
        EnableHiDPI = true;
      };

      Theme = {
        CursorTheme = gtk-theme.cursorTheme.name;
        CursorSize = 24;
        Font = gtk-theme.font.name;
      };
    };
  };

  sugarCandyNix = {
    settings = {
      ScreenWidth = 1920;
      ScreenHeight = 1080;
      FormPosition = "left";
      HaveFormBackground = true;
      PartialBlur = true;
      AccentColor = colors.mauve;
      BackgroundColor = colors.base;
      Font = gtk-theme.font.name;
      FontSize = toString gtk-theme.font.size;
      MainColor = colors.text;
      ForceHideCompletePassword = true;
      Background = lib.cleanSource ../../../assets/images/sddm/greeter.png;
    };
  };
}

