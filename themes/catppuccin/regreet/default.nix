{ gtk-theme, lib }:

let
  image = lib.cleanSource ../../../assets/images/greeter.jpg;
in
{
  regreet = {
    settings = {
      GTK = {
        # Whether to use the dark theme
        application_prefer_dark_theme = true;

        # Cursor theme name
        cursor_theme_name = gtk-theme.cursorTheme.name;

        # Font name and size
        font_name = "${gtk-theme.font.name} ${toString gtk-theme.font.size}";

        # Icon theme name
        icon_theme_name = gtk-theme.iconTheme.name;

        # GTK theme name
        theme_name = gtk-theme.theme.name;
      };

      background = {
        # Path to the background image
        path = "${image}";

        # How the background image covers the screen if the aspect ratio doesn't match
        # Available values: "Fill", "Contain", "Cover", "ScaleDown"
        fit = "Contain";
      };
    };
  };
}

